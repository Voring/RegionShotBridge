//
//  RegionShotBridge
//
//  Registers regionshot:// so scripts, Shortcuts and any other app can
//  trigger RegionShot's built-in actions through a plain URL.
//
//  regionshot://shot       -> com.moxuan.regionshot/TakeScreenshot
//  regionshot://reload     -> com.moxuan.regionshot/ReloadPrefs
//  regionshot://           -> same as shot
//

#import <UIKit/UIKit.h>
#import <stdlib.h>

static NSString *const RSBTakeScreenshotNotification = @"com.moxuan.regionshot/TakeScreenshot";
static NSString *const RSBReloadPrefsNotification = @"com.moxuan.regionshot/ReloadPrefs";

static void RSBPostDarwinNotification(NSString *name) {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         (__bridge CFStringRef)name,
                                         NULL, NULL, true);
}

@interface RSBAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL handledURL;
@end

@implementation RSBAppDelegate

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Keep the window invisible: this app only exists to own the URL scheme.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

    // Cold launch without a URL (icon tap) -> leave quickly.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (!self.handledURL) exit(0);
    });
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    self.handledURL = YES;

    NSString *host = url.host.lowercaseString ?: @"";
    if ([host isEqualToString:@"reload"]) {
        RSBPostDarwinNotification(RSBReloadPrefsNotification);
    } else {
        RSBPostDarwinNotification(RSBTakeScreenshotNotification);
    }

    // Exit fast so the launch animation is as short as possible.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        exit(0);
    });
    return YES;
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([RSBAppDelegate class]));
    }
}
