#import "RotateWall.h"

#import <Photos/Photos.h>
#import <objc/runtime.h>

#import <PhotoLibrary/PLStaticWallpaperImageViewController.h>
#import <SpringBoard/SBWallpaperController.h>
#import <SpringBoardFoundation/SBFStaticWallpaperView.h>

BOOL RTWEnable = NO;
BOOL RTWIsLandscape = NO;
NSString *RTWLandscapeAlbumName = nil;
NSString *RTWPortraitAlbumName = nil;

// Theos header 里没有, 但 dumpclass 里面有的东西
@interface PLStaticWallpaperImageViewController()

- (void)motionToggledManually:(BOOL)arg1;

@end

static void rtw_changeWallpaper(UIImage *image) {
    PLStaticWallpaperImageViewController *wallpaperImageViewController = [[PLStaticWallpaperImageViewController alloc] initWithUIImage: image];
    // classdump 结果里发现只有 _wallpaperMode 变量, 没有对应属性, 使用属性调用会 crash
    [wallpaperImageViewController setValue:@(PLWallpaperModeBoth) forKeyPath:@"wallpaperMode"];
    [wallpaperImageViewController motionToggledManually:NO];
    wallpaperImageViewController.saveWallpaperData = YES;
    [wallpaperImageViewController _savePhoto];

    // workaround, 因为我不知道 SpringBoard 里的类属于哪个 framework...
    id wallpaperController = [objc_getClass("SBWallpaperController") performSelector:@selector(sharedInstance)];
    SBFStaticWallpaperView *wallpaperView = (SBFStaticWallpaperView *)[wallpaperController valueForKeyPath:@"sharedWallpaperView"];
    UIWindow *wallpaperWindow = wallpaperView.window;
    UIView *animateView = [[UIView alloc] initWithFrame:wallpaperWindow.bounds];
    animateView.backgroundColor = UIColor.blackColor;
    animateView.alpha = 0;
    [wallpaperWindow addSubview:animateView];

    // 因为就俩动画, 就直接嵌套起来了
    [UIView animateWithDuration:0.3
        animations:^{
            animateView.alpha = 1;
        }
        completion:^(BOOL finished){
            [UIView animateWithDuration:0.3
                animations:^{
                    animateView.alpha = 0;
                }
                completion:^(BOOL finished){
                    [animateView removeFromSuperview];
            }];
    }];
}

static void rtw_changeWallpaperWithOrientation(BOOL isLandscape) {
    if (RTWIsLandscape == isLandscape) {
        return;
    }
    RTWIsLandscape = isLandscape;
    NSString *ablumName = isLandscape? RTWLandscapeAlbumName: RTWPortraitAlbumName;
    PHFetchResult *collectionArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHAssetCollection *album = nil;
    for (PHAssetCollection *collection in collectionArray) {
        if ([collection.localizedTitle isEqual:ablumName]) {
            album = collection;
            break;
        }
    }
    if(!album) {
        return;
    }
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];
    if(assets.count < 1) {
        return;
    }
    int index = arc4random() % assets.count;
    PHAsset *asset = (PHAsset*)assets[index];

    // 照片是异步获取的, 本来也没几行, 嵌套调用了
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *string, UIImageOrientation orientation, NSDictionary *info) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        rtw_changeWallpaper(image);
    }];
}

void rtw_orientationChanged(CFNotificationCenterRef center,
                                               void *observer,
                                        CFStringRef name,
                                         const void *object,
                                    CFDictionaryRef userInfo) {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft: {
            rtw_changeWallpaperWithOrientation(YES);
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            rtw_changeWallpaperWithOrientation(YES);
            break;
        }
        case UIDeviceOrientationPortrait: {
            rtw_changeWallpaperWithOrientation(NO);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            rtw_changeWallpaperWithOrientation(NO);
            break;
        }
        default:
            break;
    }
}