#import "UABTestsAppDelegate.h"

@implementation UABTestsAppDelegate

+ (UINavigationController *)rootNavigationController
{
    UABTestsAppDelegate *delegate = (UABTestsAppDelegate *) [UIApplication sharedApplication].delegate;
    return (UINavigationController *) delegate.window.rootViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UINavigationController *nc = [[UINavigationController alloc] init];
    nc.title = @"Running tests...";
    self.window.rootViewController = nc;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end