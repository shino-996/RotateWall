#import "RotateWall.h"
#import <UIKit/UIKit.h>

static NSString * const RTWPreferencePath = @"/var/mobile/Library/Preferences/space.shino.rotatewall.preference.plist";
static NSString * const RTWPreferenceEnableKey = @"enable";
static NSString * const RTWPreferenceLandscapeKey = @"landscape";
static NSString * const RTWPreferencePortraitKey = @"portrait";
SBFStaticWallpaperImageView *RTWImageView;

%hook SpringBoard
- (void)noteInterfaceOrientationChanged:(UIDeviceOrientation)orientation
                               duration:(double)duration
                 updateMirroredDisplays:(BOOL)update
                                  force:(BOOL)force
                             logMessage:(id)message
{
    if (RTWEnable) {
        rtw_orientationChanged(orientation);
    }
    %orig;
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

%hook SBFStaticWallpaperImageView
- (instancetype)initWithImage:(UIImage *)image
{
    RTWImageView = %orig(image);
    RTWImageView.contentMode = UIViewContentModeScaleAspectFit;
    return RTWImageView;
}
%end