#import <PhotoLibrary/PLStaticWallpaperImageViewController.h>
#import <Photos/Photos.h>
#import <objc/runtime.h>

@interface SBFStaticWallpaperView : UIView
@end

static BOOL SNEnable = NO;
static BOOL SNIsLandscape = NO;
static NSString *SNLandscape = @"";
static NSString *SNPortrait = @"";
static SBFStaticWallpaperView *SNWallpaperView =nil;