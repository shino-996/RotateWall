#import "RotateWall.h"

static void SNChangeWallpaperFor(UIImage *image) {
    Class wallpaperClass = NSClassFromString(@"PLStaticWallpaperImageViewController");
    id wallpaperViewController = [[wallpaperClass alloc] performSelector:NSSelectorFromString(@"initWithUIImage:") withObject:image];
    [wallpaperViewController setValue:@(NO) forKeyPath:@"allowsEditing"];
    [wallpaperViewController  setValue:@(YES) forKeyPath:@"saveWallpaperData"];
    [wallpaperViewController performSelector:@selector(setImageAsHomeScreenAndLockScreenClicked:) withObject:nil];
    [wallpaperViewController performSelector:@selector(release)];
}

static void SNChangeWallpaperFor(BOOL isLandscape) {
    if(SNIsLandscape == isLandscape) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        SNWallpaperView.alpha = 0;
    }];
    SNIsLandscape = isLandscape;
    NSString *wallpaperCollections = @"";
    if(isLandscape) {
        wallpaperCollections = SNLandscape;
    } else {
        wallpaperCollections = SNPortrait;
    }
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:NULL];
    PHAssetCollection *sclectedCollection = NULL;
    for(int i = 0; i < collections.count; ++i) {
        PHAssetCollection *collection = (PHAssetCollection*)collections[i];
        if([collection.localizedTitle  isEqual: wallpaperCollections]) {
            sclectedCollection = collection;
            break;
        }
    }
    if([sclectedCollection isEqual:NULL]) {
        return;
    }
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:sclectedCollection options:NULL];
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
            NSLog(@"landscape left");
            SNChangeWallpaperFor(YES);
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            NSLog(@"landscape right");
            SNChangeWallpaperFor(YES);
            break;
        }
        case UIDeviceOrientationPortrait: {
            NSLog(@"portrait up");
            SNChangeWallpaperFor(NO);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            NSLog(@"portrait down");
            SNChangeWallpaperFor(NO);
            break;
        }
        default:
            break;
    }
}

%group common
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
%end //common group

%group iOS9
%hook SBFStaticWallpaperView
-(id)initWithFrame:(CGRect)arg1 wallpaperImage:(id)arg2 variant:(long long)arg3 options:(NSUInteger)arg4 {
    SBFStaticWallpaperView *view = %orig;
    view.alpha = 0.2;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    }];
    SNWallpaperView = view;
    return view;
}
%end
%end //iOS9 group

%group iOS9_plus
%hook SBFStaticWallpaperView
- (id)initWithFrame:(struct CGRect)arg1 wallpaperImage:(id)arg2 cacheGroup:(id)arg3 variant:(long long)arg4 options:(unsigned long long)arg5 {
    SBFStaticWallpaperView *view = %orig;
    view.alpha = 0.2;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    }];
    SNWallpaperView = view;
    return view;
}
%end
%end //iOS9_plus group

%ctor {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/space.shino.rotatewall.preference.plist"];
    SNEnable = [settings[@"enable"] boolValue];
    SNLandscape = (NSString*)settings[@"landscape"];
    SNPortrait = (NSString*)settings[@"portrait"];
    %init;
    %init(common);
    if(kCFCoreFoundationVersionNumber >= 1300) {
        %init(iOS9_plus);
    } else {
        %init(iOS9);
    }
}