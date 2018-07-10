#import "RotateWall.h"

static void SNChangeWallpaperFor(UIImage *image) {
    Class wallpaperClass = NSClassFromString(@"PLStaticWallpaperImageViewController");
    id wallpaperViewController = [[wallpaperClass alloc] performSelector:NSSelectorFromString(@"initWithUIImage:") withObject:image];
    [wallpaperViewController setValue:@(NO) forKeyPath:@"allowsEditing"];
    [wallpaperViewController  setValue:@(YES) forKeyPath:@"saveWallpaperData"];

    // animate start
    UIWindow *window = [[UIWindow alloc] init];
    window.frame =  [UIScreen mainScreen].bounds;
    window.windowLevel = 2005;
    window.alpha = 0;
    [window makeKeyAndVisible];
    [window setBackgroundColor: [UIColor blackColor]];
    [wallpaperViewController performSelector:@selector(setImageAsHomeScreenAndLockScreenClicked:) withObject:nil];
    [wallpaperViewController performSelector:@selector(release)];
    [UIView animateWithDuration:0.3
        animations:^{
            window.alpha = 1;
        }
        completion:^(BOOL finished){
            [UIView animateWithDuration:0.3
                animations:^{
                    window.alpha = 0;
                }
                completion:^(BOOL finished){
                    [window release];
                }];
        }];
}

static void SNChangeWallpaperFor(BOOL isLandscape) {
    if(SNIsLandscape == isLandscape) {
        return;
    }
    SNIsLandscape = isLandscape;
    NSString *albumName = @"";
    if(isLandscape) {
        albumName = SNLandscape;
    } else {
        albumName = SNPortrait;
    }
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:NULL];
    PHAssetCollection *album = NULL;
    for(int i = 0; i < collections.count; ++i) {
        PHAssetCollection *collection = (PHAssetCollection*)collections[i];
        if([collection.localizedTitle  isEqual: albumName]) {
            album = collection;
            break;
        }
    }
    if([album isEqual:NULL]) {
        return;
    }
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:album options:NULL];
    if(assets.count < 1) {
        return;
    }
    int index = arc4random() % assets.count;
    PHAsset *asset = (PHAsset*)assets[index];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:NULL resultHandler:^(NSData *data, NSString *string, UIImageOrientation orientation, NSDictionary *info) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        SNChangeWallpaperFor(image);
    }];
}

static void SNDeviceOrientationChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft: {
            SNChangeWallpaperFor(YES);
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            SNChangeWallpaperFor(YES);
            break;
        }
        case UIDeviceOrientationPortrait: {
            SNChangeWallpaperFor(NO);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            SNChangeWallpaperFor(NO);
            break;
        }
        default:
            break;
    }
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    if(SNEnable) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                        NULL,
                                        SNDeviceOrientationChangedCallback,
                                        (CFStringRef)UIApplicationWillChangeStatusBarOrientationNotification,
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);
    }
}
%end

%ctor {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/space.shino.rotatewall.preference.plist"];
    SNEnable = [settings[@"enable"] boolValue];
    SNLandscape = (NSString*)settings[@"landscape"];
    SNPortrait = (NSString*)settings[@"portrait"];
    %init;
}