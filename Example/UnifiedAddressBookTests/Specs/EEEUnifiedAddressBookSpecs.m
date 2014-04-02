//
//  EEEUnifiedAddressBookSpecs.m
//  UnifiedAddressBook
//
//  Created by Eric-Paul Lecluse on 02-04-14.
//  Copyright 2014 epologee. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "EEEUnifiedAddressBook.h"

SPEC_BEGIN(EEEUnifiedAddressBookSpecs)
        ABAddressBookRef (^addressBookViaGrantedBlock)() = ^ABAddressBookRef {
            __block ABAddressBookRef ab;
            __block BOOL resumed = NO;
            __block BOOL granted = NO;

            [EEEUnifiedAddressBook accessAddressBookWithGranted:^(ABAddressBookRef addressBook) {
                ab = CFRetainIfNotNULL(addressBook);
                granted = YES;
                resumed = YES;
            }
                                                         denied:^(BOOL restricted) {
                                                             resumed = YES;
                                                         }];

            [[expectFutureValue(theValue(resumed)) shouldEventually] beYes];
            [[theValue(granted) should] beYes];
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

                    it(@"has a list of cards", ^{
                        [[[sut allCards] should] beNonNil];
                        [[[sut allCards] should] haveCountOfAtLeast:1];
                    });
                });
            });
        });

        SPEC_END
