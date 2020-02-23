#import "RotateWall.h"

#import <Photos/Photos.h>
#import <objc/runtime.h>

BOOL RTWEnable = NO;
BOOL RTWIsLandscape = NO;
NSString *RTWLandscapeAlbumName = nil;
NSString *RTWPortraitAlbumName = nil;

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
        RTWImageView.image = image;
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