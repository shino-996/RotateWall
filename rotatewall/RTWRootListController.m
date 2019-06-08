#include "RTWRootListController.h"
#import <Photos/Photos.h>

@implementation RTWRootListController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    return _specifiers;
}

- (NSArray *)getAlbums
{
    NSMutableArray *albumNameArray = [[NSMutableArray alloc] init];

    PHFetchResult *collectionArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum 
                                                                          subtype:PHAssetCollectionSubtypeAny 
                                                                          options:NULL];
    for (PHAssetCollection *collection in collectionArray) {
        NSString *albumName = collection.localizedTitle;
        [albumNameArray addObject:albumName];
    }
    return albumNameArray;
}

- (void)respring 
{
    popen("killall -9 SpringBoard", "r");
}
@end
