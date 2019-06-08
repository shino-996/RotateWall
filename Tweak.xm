#import "RotateWall.h"
#import <Foundation/Foundation.h>

static NSString * const RTWPreferencePath = @"/User/Library/Preferences/space.shino.rotatewall.preference.plist";
static NSString * const RTWPreferenceEnableKey = @"enable";
static NSString * const RTWPreferenceLandscapeKey = @"landscape";
static NSString * const RTWPreferencePortraitKey = @"portrait";

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
    %orig;
    if(!RTWEnable) {
        return;
    }
    // 为了使动画更自然, 监听将要开始旋转的通知
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    NULL,
                                    rtw_orientationChanged,
                                    (CFStringRef)UIApplicationWillChangeStatusBarOrientationNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);

    // 亮屏通知
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    rtw_orientationChanged,
                                    CFSTR("com.apple.springboard.hasBlankedScreen"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
}
%end

%ctor
{
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:RTWPreferencePath];
    RTWEnable = [settings[RTWPreferenceEnableKey] boolValue];
    RTWLandscapeAlbumName = [settings[RTWPreferenceLandscapeKey] stringValue];
    RTWPortraitAlbumName = [settings[RTWPreferencePortraitKey] stringValue];
    %init;
}

%hook SBFStaticWallpaperView
+ (BOOL)_allowsParallax
{
    if (RTWEnable) {
        return NO;
    } else {
        return %orig;
    }
}
%end