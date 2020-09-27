#import <Foundation/Foundation.h>

extern BOOL RTWEnable;
extern BOOL RTWIsLandscape;
extern NSString *RTWLandscapeAlbumName;
extern NSString *RTWPortraitAlbumName;

@interface SBFStaticWallpaperImageView: UIImageView

@end
extern SBFStaticWallpaperImageView *RTWImageView;

void rtw_orientationChanged(UIDeviceOrientation deviceOrientation);