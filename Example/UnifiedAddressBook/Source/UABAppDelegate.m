//
//  UABAppDelegate.m
//  UnifiedAddressBook
//
//  Created by Eric-Paul Lecluse on 02-04-14.
//  Copyright (c) 2014 epologee. All rights reserved.
//

#import "UABAppDelegate.h"

@implementation UABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
