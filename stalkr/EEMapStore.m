// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEMapStore.h"

#import "EEAnnotation.h"
#import "EEMap.h"

@interface EEMapStore ()

@property (nonatomic, strong) NSMutableArray *privateMaps;

@end

@implementation EEMapStore

+ (instancetype)sharedStore
{
  static EEMapStore *sharedStore;

  if(!sharedStore){
    sharedStore = [[self alloc] initPrivate];
  }
  return sharedStore;
}

- (instancetype)init
{
  [NSException raise:@"Singleton" format:@"Use +[EEMapStore sharedStore"];
  return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if(self) {
    _privateMaps = [aDecoder decodeObjectForKey:@"privateMaps"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_privateMaps forKey:@"privateMaps"];
}

- (NSString *)itemArchivePath
{
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories firstObject];
  return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (void)saveMaps
{
  NSString *path = [self itemArchivePath];
  [NSKeyedArchiver archiveRootObject:_privateMaps toFile:path];
}

- (instancetype)initPrivate
{
  self = [super init];
  if (self) {
    _allImages = [[NSMutableArray alloc] init];
    NSString *path = [self itemArchivePath];
    _privateMaps = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(!_privateMaps) {
      _privateMaps = [[NSMutableArray alloc] init];
    }
  }
  return self;
}

- (NSArray *)allMapTitles
{
  NSMutableArray *mapTitles = [[NSMutableArray alloc] init];
  int count = (int)[_privateMaps count];
  for(int i = 0; i < count; i++) {
    EEMap *current = _privateMaps[i];
    mapTitles[i] = current.mapTitle;
  }
  return [mapTitles copy];
}

- (NSMutableArray *)allPointsForMap:(EEMap *)map
{
  return map.points;
}

- (void)addAnnotation:(EEAnnotation *)annotation forMap:(EEMap *)currentMap
{
  [currentMap.annotations addObject:annotation];
}

- (void)removeAnnotation:(EEAnnotation *)annotation forMap:(EEMap *)currentMap
{
  [currentMap.annotations removeObject:annotation];
}

- (NSArray *)allAnnotationsForMap:(EEMap *)currentMap
{
  return currentMap.annotations;
}

- (void)addLocation:(CLLocation *)currentLocation forMap:(EEMap *)currentMap
{
  [currentMap.points addObject:currentLocation];
}

- (void)addMap:(EEMap *)currentMap
{
  [_privateMaps addObject:currentMap];
}

- (void)removeMap:(EEMap *)currentMap
{
  [_privateMaps removeObject:currentMap];
}

- (NSArray *)allMaps
{
  return [_privateMaps copy];
}

- (void)removeAllMaps
{
  [_privateMaps removeAllObjects];
}

- (EEMap *)findMapForKey:(NSString *)mapKey
{
  for (EEMap *map in _privateMaps) {
    if ([map.mapKey isEqualToString:mapKey]) {
      return map;
    }
  }
  return nil;
}

@end
