#import <PhotoLibrary/PLStaticWallpaperImageViewController.h>
#import <Photos/Photos.h>
#import <objc/runtime.h>

static BOOL SNIsLandscape = NO;

static void SNChangeWallpaperFor(BOOL isLandscape) {
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:NULL];
    PHAssetCollection *sclectedCollection = NULL;
    NSString *wallpaperCollections = @"";
    if(isLandscape) {
        wallpaperCollections = @"WallpaperLandscape";
    } else {
        wallpaperCollections = @"WallpaperPortrait";
    }
    for(int i = 0; i < collections.count; ++i) {
        PHAssetCollection *collection = (PHAssetCollection*)collections[i];
        if([collection.localizedTitle  isEqual: wallpaperCollections]) {
            sclectedCollection = collection;
            break;
        }
    }
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:sclectedCollection options:NULL];
    PHAsset *asset = (PHAsset*)[assets firstObject];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:NULL resultHandler:^(NSData *data, NSString *string, UIImageOrientation orientation, NSDictionary *info) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        Class wallpaperClass = NSClassFromString(@"PLStaticWallpaperImageViewController");
        id wallpaperViewController = [[wallpaperClass alloc] performSelector:NSSelectorFromString(@"initWithUIImage:") withObject:image];
        [wallpaperViewController setValue:@(NO) forKeyPath:@"allowsEditing"];
        [wallpaperViewController  setValue:@(YES) forKeyPath:@"saveWallpaperData"];
        [wallpaperViewController performSelector:@selector(setImageAsHomeScreenAndLockScreenClicked:) withObject:nil];
        [wallpaperViewController performSelector:@selector(release)];
    }];
}

static void SNDeviceOrientationChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"Screen Left");
        case UIDeviceOrientationLandscapeRight: {
            NSLog(@"Screen Right");
            if(SNIsLandscape == YES) {
                break;
            }
            SNIsLandscape = YES;
            SNChangeWallpaperFor(YES);
            break;
        }
        case UIDeviceOrientationPortrait:
            NSLog(@"Screen Portrait");
        case UIDeviceOrientationPortraitUpsideDown: {
            NSLog(@"Screen UnPortrait");
            if(SNIsLandscape == NO) {
                break;
            }
            SNIsLandscape = NO;
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
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    NULL,
                                    SNDeviceOrientationChangedCallback,
                                    (CFStringRef)UIDeviceOrientationDidChangeNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
}
%end