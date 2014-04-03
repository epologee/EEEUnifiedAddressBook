// Copyright (c) 2012 Twelve Twenty (http://twelvetwenty.nl)
//
// Permission is hereby granted, free of charge, to any unifiedRecord obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <CoreData/CoreData.h>
#import "EEEUnifiedAddressBook.h"
#import "EEECDLinkedRecord.h"
#import "EEECDUnifiedRecord.h"
#import "NSManagedObjectContext+TTTBatchManipulation.h"

#ifndef OR_EMPTY
#define OR_EMPTY(VALUE)    ({ __typeof__(VALUE) __value = (VALUE); __value ? __value : @""; })
#endif

void CFReleaseIfNotNULL(CFTypeRef ref) {
    if (ref != NULL)
    {
        CFRelease(ref);
    }
}

CFTypeRef CFRetainIfNotNULL(CFTypeRef ref) {
    if (ref != NULL)
    {
        return CFRetain(ref);
    }

    return ref;
}

void eee_handleABExternalChange(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    NSLog(@"External change of the address book detected. Call updateAddressBookWithCompletion: to update the index.");
    [[NSNotificationCenter defaultCenter] postNotificationName:EEE_UNIFIED_ADDRESS_BOOK_REQUEST_UPDATE_NOTIFICATION object:nil];
}

@interface EEEUnifiedAddressBook ()

@property(nonatomic, strong) NSManagedObjectModel *objectModel;
@property(nonatomic, strong) NSPersistentStoreCoordinator *storeCoordinator;
@property(nonatomic, strong) NSManagedObjectContext *mainContext;
@property(nonatomic, readwrite) ABAddressBookRef addressBook;

@end

@implementation EEEUnifiedAddressBook

+ (void)accessAddressBookWithGranted:(void (^)(ABAddressBookRef addressBook))accessGrantedBlock denied:(void (^)(BOOL restricted))accessDeniedBlock
{
    BOOL requireAccessRequest = NO;

    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusRestricted:
        case kABAuthorizationStatusDenied:
            accessDeniedBlock(status == kABAuthorizationStatusRestricted);
            return;
        case kABAuthorizationStatusNotDetermined:
            // wait for asking permission
            requireAccessRequest = YES;
            break;
        case kABAuthorizationStatusAuthorized:
            // create the address book
            break;
    }

    __block ABAddressBookRef addressBook;

    CFErrorRef error = NULL;
    addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook != NULL)
    {
        if (!requireAccessRequest)
        {
            accessGrantedBlock(addressBook);
        }
        else
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_barrier_sync(dispatch_get_main_queue(), ^{
                    if (granted)
                    {
                        // Constructing a new address book, since the
                        // background block invalidated our existing instance.
                        ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
                        accessGrantedBlock(ab);
                        CFReleaseIfNotNULL(ab);
                    }
                    else
                    {
                        accessDeniedBlock(NO);
                    }
                });
            });
        }
    }
    else
    {
        // Catch 22 - We checked whether access was required and it was not, yet here we are with a NULL address book. Let's pray we never get here.
        [[NSException exceptionWithName:@"EEE_UNIFIED_ADDRESS_BOOK_EXCEPTION"
                                 reason:[NSString stringWithFormat:@"Could not create address book: %@", error]
                               userInfo:nil] raise];
    }

    CFReleaseIfNotNULL(addressBook);
}

+ (ABAddressBookRef)newAddressBookInline
{
    ABAddressBookRef addressBook = NULL;
    CFErrorRef error = NULL;

    addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook == NULL)
    {
        // Catch 22 - We checked whether access was required and it was not, yet here we are with a NULL address book. Let's pray we never get here.
        [[NSException exceptionWithName:@"EEE_UNIFIED_ADDRESS_BOOK_EXCEPTION"
                                 reason:[NSString stringWithFormat:@"Could not create address book: %@", error]
                               userInfo:nil] raise];
    }

    return addressBook;
}

/**
 * Without an address book, this class will not initialize.
 * Use `+accessAddressBookWithGranted:denied:` to get at that address book reference.
 */
- (id)initWithAddressBook:(ABAddressBookRef)addressBook
{
    self = [super init];

    if (addressBook == NULL)
    {
        self = nil;
    }

    if (self)
    {

        if (![self setupCoreData])
        {
            self = nil;
            return self;
        }

        self.addressBook = addressBook;
        ABAddressBookRegisterExternalChangeCallback(self.addressBook, eee_handleABExternalChange, (__bridge void *) self);
    }

    return self;
}

- (void)setAddressBook:(ABAddressBookRef)addressBook
{
    CFRetainIfNotNULL(addressBook);
    CFReleaseIfNotNULL(_addressBook);
    _addressBook = addressBook;
}

- (void)updateAddressBookWithCompletion:(void (^)())completion
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("nl.twelvetwenty.EEEUnifiedAddressBook", NULL);

    dispatch_async(backgroundQueue, ^{
        ABAddressBookRef addressBook = [[self class] newAddressBookInline];

        if ([self unifyAddressBook:addressBook])
        {
            // completion callback
            dispatch_async(dispatch_get_main_queue(), completion);
        }
        else
        {
            [[NSException exceptionWithName:@"EEE_UNIFIED_ADDRESS_BOOK_EXCEPTION" reason:@"Could not unify address book" userInfo:nil] raise];
        }

        CFReleaseIfNotNULL(addressBook);
    });
}

#pragma - Indexing

- (BOOL)unifyAddressBook:(ABAddressBookRef)addressBook
{
    NSManagedObjectContext *context = [self newContext];

    // Set the updated flag to NO for all linked cards.
    NSError *error = nil;
    [context ttt_deleteAllEntitiesNamed:[EEECDLinkedRecord entityName] error:&error];
    [context ttt_deleteAllEntitiesNamed:[EEECDUnifiedRecord entityName] error:&error];

    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    NSArray *records = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeopleInSource(addressBook, source);
    ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, ABPersonGetSortOrdering());
    CFReleaseIfNotNULL(source);

    NSUInteger idx = 0;
    NSUInteger count = [records count];
    for (id untypedRecord in records)
    {
        ABRecordRef unifiedRecordRef = (__bridge ABRecordRef) untypedRecord;
        NSNumber *recordID = [NSNumber numberWithInteger:ABRecordGetRecordID(unifiedRecordRef)];

        EEECDUnifiedRecord *unifiedRecord = [EEECDUnifiedRecord insertInManagedObjectContext:context];
        unifiedRecord.recordID = recordID;
        unifiedRecord.sortFieldFirstName = [self createSortFieldForRecord:unifiedRecordRef sortOrdering:kABPersonSortByFirstName];
        unifiedRecord.sortFieldLastName = [self createSortFieldForRecord:unifiedRecordRef sortOrdering:kABPersonSortByLastName];
        unifiedRecord.positionValue = idx / (float) count;

        NSArray *linkedRecordsArray = (__bridge_transfer NSArray *) ABPersonCopyArrayOfAllLinkedPeople(unifiedRecordRef);
        for (id untypedLinkedRecord in linkedRecordsArray)
        {
            ABRecordRef linkedRecordRef = (__bridge ABRecordRef) untypedLinkedRecord;
            NSNumber *linkedRecordID = [NSNumber numberWithInteger:ABRecordGetRecordID(linkedRecordRef)];

            EEECDLinkedRecord *linkedRecord = [EEECDLinkedRecord insertInManagedObjectContext:context];
            linkedRecord.recordID = linkedRecordID;
            linkedRecord.unifiedRecord = unifiedRecord;
        }

        idx++;
    }

    if (![context save:&error])
    {
        NSLog(@"Could not save background context: %@", error);
        return NO;
    }

    return YES;
}

- (NSString *)createSortFieldForRecord:(ABRecordRef)record sortOrdering:(ABPersonSortOrdering)sortOrdering
{
    NSString *firstName = (__bridge_transfer NSString *) ABRecordCopyValue(record, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *) ABRecordCopyValue(record, kABPersonLastNameProperty);
    NSString *middleName = (__bridge_transfer NSString *) ABRecordCopyValue(record, kABPersonMiddleNameProperty);
    NSString *companyName = (__bridge_transfer NSString *) ABRecordCopyValue(record, kABPersonOrganizationProperty);
    NSString *nickName = (__bridge_transfer NSString *) ABRecordCopyValue(record, kABPersonNicknameProperty);

    switch (sortOrdering)
    {
        case kABPersonSortByFirstName:
        {
            return [@[OR_EMPTY(firstName), OR_EMPTY(lastName), OR_EMPTY(middleName), OR_EMPTY(companyName), OR_EMPTY(nickName)] componentsJoinedByString:@""];
        }
        default:
        case kABPersonSortByLastName:
        {
            return [@[OR_EMPTY(lastName), OR_EMPTY(middleName), OR_EMPTY(firstName), OR_EMPTY(companyName), OR_EMPTY(nickName)] componentsJoinedByString:@""];
        }
    }
}

#pragma - Fetching cards & searching

- (NSArray *)allCards
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[EEECDUnifiedRecord entityName]];
    NSString *sortKey = EEECDUnifiedRecordAttributes.position;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]];

    NSError *error = nil;
    NSArray *results = [self.mainContext executeFetchRequest:request error:&error];
    NSMutableArray *cards = nil;
    if (results)
    {
        cards = [NSMutableArray arrayWithCapacity:results.count];
        for (EEECDUnifiedRecord *record in results)
        {
            [cards addObject:record.personCard];
        }
    }

    return cards;
}

- (void)cardsMatchingQuery:(NSString *)query withAsyncResults:(void (^)(NSArray *))resultsBlock
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("nl.twelvetwenty.EEEUnifiedAddressBook", NULL);

    dispatch_async(backgroundQueue, ^{
        NSArray *cards = [self cardsMatchingQuery:query];
        dispatch_async(dispatch_get_main_queue(), ^{resultsBlock(cards);});
    });
}

- (NSArray *)cardsMatchingQuery:(NSString *)query
{
    ABAddressBookRef addressBook = [[self class] newAddressBookInline];
    NSManagedObjectContext *context = [NSThread mainThread] ? self.mainContext : [self newContext];
    CFStringRef queryRef = (__bridge CFStringRef) query;
    CFArrayRef recordsRef = ABAddressBookCopyPeopleWithName(addressBook, queryRef);
    NSArray *records = (__bridge_transfer NSArray *) recordsRef;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[EEECDUnifiedRecord entityName]];
    NSString *sortKey = EEECDUnifiedRecordAttributes.position;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]];

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSMutableArray *cards = nil;

    if (results)
    {
        if (query == nil || [query isEqualToString:@""])
        {
            cards = [NSMutableArray arrayWithCapacity:results.count];
            for (EEECDUnifiedRecord *record in results)
            {
                [cards addObject:record.personCard];
            }
        }
        else
        {
            NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(EEECDUnifiedRecord *evaluatedObject, NSDictionary *bindings) {
                for (id untypedRecord in records)
                {
                    ABRecordRef record = (__bridge ABRecordRef) untypedRecord;
                    ABRecordID recordID = ABRecordGetRecordID(record);
                    if (evaluatedObject.recordIDValue == recordID) return YES;
                }
                return NO;
            }];
            NSArray *filteredResults = [results filteredArrayUsingPredicate:filter];

            cards = [NSMutableArray arrayWithCapacity:filteredResults.count];
            for (EEECDUnifiedRecord *record in filteredResults)
            {
                [cards addObject:record.personCard];
            }
        }
    }

    CFReleaseIfNotNULL(addressBook);
    return cards;
}

#pragma - Core Data

- (BOOL)setupCoreData
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"EEEUnifiedAddressBook" withExtension:@"momd"];
    self.objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];

    self.storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    if (NO)
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *storeURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"EEEUnifiedAddressBook.store"]];
        NSError *error = nil;
        BOOL giveUp = NO;
        BOOL storeAdded = NO;
        while (!giveUp && !storeAdded)
        {
            storeAdded = ([self.storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:options
                                                                      error:&error] != nil);
            if (!storeAdded)
            {
                NSLog(@"Could not add store to coordinator: %@", error);
                if (!giveUp)
                {
                    if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error])
                    {
                        NSLog(@"Deleted sqlite store to circumvent migration.");
                    }
                    else
                    {
                        NSLog(@"Could not delete the existing store: %@", error);
                    }

                    giveUp = YES;
                }
                else
                {
                    // give up.
                    return NO;
                }
            }
        }
    }
    else
    {
        NSError *error = nil;
        BOOL giveUp = NO;
        BOOL storeAdded = NO;
        while (!giveUp && !storeAdded)
        {
            storeAdded = ([self.storeCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error] != nil);
            if (!storeAdded)
            {
                NSLog(@"Could not add store to coordinator: %@", error);
                giveUp = YES;
            }
        }
    }

    self.mainContext = [self newContext];
    return YES;
}

- (NSManagedObjectContext *)newContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:self.storeCoordinator];
    [context setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    [context setUndoManager:nil];

    if (![NSThread isMainThread])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDidSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:context];
    }

    return context;
}

- (void)handleDidSaveNotification:(NSNotification *)notification
{
    // bump the notification to the main thread for processing.
    [self.mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                       withObject:notification
                                    waitUntilDone:YES];
}

@end

