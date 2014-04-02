//
//  EEEUnifiedAddressBookSpecs.m
//  UnifiedAddressBook
//
//  Created by Eric-Paul Lecluse on 02-04-14.
//  Copyright 2014 epologee. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "EEEUnifiedAddressBook.h"
#import "EEEUnifiedCard.h"
#import "UABTestsAppDelegate.h"

SPEC_BEGIN(EEEUnifiedAddressBookSpecs)
        ABAddressBookRef (^addressBookViaGrantedBlock)() = ^ABAddressBookRef {
            __block ABAddressBookRef ab;
            __block BOOL resumed = NO;
            __block BOOL granted = NO;

            UIViewController *titleVC = [[UIViewController alloc] init];
            titleVC.title = @"Please allow access manually";
            [[UABTestsAppDelegate rootNavigationController] pushViewController:titleVC animated:NO];

            [EEEUnifiedAddressBook accessAddressBookWithGranted:^(ABAddressBookRef addressBook) {
                ab = CFRetainIfNotNULL(addressBook);
                granted = YES;
                resumed = YES;
            }
                                                         denied:^(BOOL restricted) {
                                                             resumed = YES;
                                                         }];

            [[expectFutureValue(theValue(resumed)) shouldEventuallyBeforeTimingOutAfter(15)] beYes];
            [[theValue(granted) should] beYes];

            [[UABTestsAppDelegate rootNavigationController] popViewControllerAnimated:NO];
            return ab;
        };

        describe(@"EEEUnifiedAddressBook", ^{
            context(@"with access to the AB (currently requires you to manually tap 'allow')", ^{
                __block EEEUnifiedAddressBook *sut;

                beforeEach(^{
                    ABAddressBookRef ab = addressBookViaGrantedBlock();
                    sut = [[EEEUnifiedAddressBook alloc] initWithAddressBook:ab];
                    CFReleaseIfNotNULL(ab);
                });

                context(@"unified", ^{
                    beforeEach(^{
                        __block BOOL resumed = NO;

                        [sut updateAddressBookWithCompletion:^{
                            resumed = YES;
                        }];

                        [[expectFutureValue(theValue(resumed)) shouldEventually] beYes];
                    });

                    context(@"cards", ^{
#ifdef TARGET_IPHONE_SIMULATOR
                        beforeAll(^{
                            NSDictionary *numbersByName = @{
                                    @"Eric-Paul" : @"0612345678",
                                    @"Marijn" : @"0687654321",
                                    @"Jankees" : @"0612341234"
                            };

                            ABAddressBookRef ab = sut.addressBook;

                            [numbersByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *phoneNumber, BOOL *stop) {
                                if ([[sut cardsMatchingQuery:name] count] == 0)
                                {
                                    ABRecordRef personRef = ABPersonCreate();
                                    ABRecordSetValue(personRef, kABPersonFirstNameProperty, (__bridge CFTypeRef) name, NULL);

                                    ABMutableMultiValueRef phoneNumberRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                                    ABMultiValueAddValueAndLabel(phoneNumberRef, (__bridge CFTypeRef) phoneNumber, kABPersonPhoneMobileLabel, NULL);
                                    ABRecordSetValue(personRef, kABPersonPhoneProperty, phoneNumberRef, nil);

                                    bool added = ABAddressBookAddRecord(ab, personRef, NULL);
                                    [[theValue(added == true) should] beYes];
                                }
                            }];

                            if (ABAddressBookHasUnsavedChanges(ab) == true)
                            {
                                bool saved = ABAddressBookSave(ab, NULL);
                                [[theValue(saved == true) should] beYes];

                                __block BOOL resumed = NO;
                                [sut updateAddressBookWithCompletion:^{
                                    resumed = YES;
                                }];

                                [[expectFutureValue(theValue(resumed)) shouldEventually] beYes];
                            }
                        });
#endif

                        it(@"has a list of cards", ^{
                            [[[sut allCards] should] beNonNil];
                            [[[sut allCards] should] haveCountOfAtLeast:3];
                        });

                        it(@"finds a card", ^{
                            NSArray *results = [sut cardsMatchingQuery:@"Jankees"];

                            EEEUnifiedCard *card = [results lastObject];
                            [card setAddressBook:sut.addressBook];

                            [[card.compositeName should] equal:@"Jankees"];
                        });
                    });
                });
            });
        });

        SPEC_END
