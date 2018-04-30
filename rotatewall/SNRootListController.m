#include "SNRootListController.h"
#import <Photos/Photos.h>

@implementation SNRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (NSArray*)getAlbums {
  NSMutableArray *albumNameArray = [[NSMutableArray alloc] init];

  PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:NULL];
  for(int i = 0; i < collections.count; ++i) {
      PHAssetCollection *collection = (PHAssetCollection*)collections[i];
      NSString *albumName = collection.localizedTitle;
      [albumNameArray addObject:albumName];
  }
  return albumNameArray;
}

- (void)respring {
  popen("killall -9 SpringBoard", "r");
}
@end
