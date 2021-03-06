//
//  main.m
//  UnifiedAddressBook
//
//  Created by Eric-Paul Lecluse on 02-04-14.
//  Copyright (c) 2014 epologee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UABAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        BOOL runningTests = (NSClassFromString(@"UABTestsAppDelegate") != nil);
        if (runningTests)
        {
            return UIApplicationMain(argc, argv, nil, @"UABTestsAppDelegate");
        }

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([UABAppDelegate class]));
    }
}
