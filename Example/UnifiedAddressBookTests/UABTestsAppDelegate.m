#import "UABTestsAppDelegate.h"

@implementation UABTestsAppDelegate

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