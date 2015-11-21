// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEMap.h"

@implementation EEMap

- (instancetype)init
{
  self = [super init];
  if(self) {
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    _mapKey = key;
    _points = [[NSMutableArray alloc] init];
    _annotations = [[NSMutableArray alloc] init];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if(self) {
    _points = [aDecoder decodeObjectForKey:@"points"];
    _mapKey = [aDecoder decodeObjectForKey:@"mapKey"];
    _mapTitle = [aDecoder decodeObjectForKey:@"mapTitle"];
    _annotations = [aDecoder decodeObjectForKey:@"annotations"];
    _location = [aDecoder decodeObjectForKey:@"location"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_points forKey:@"points"];
  [aCoder encodeObject:_mapKey forKey:@"mapKey"];
  [aCoder encodeObject:_mapTitle forKey:@"mapTitle"];
  [aCoder encodeObject:_annotations forKey:@"annotations"];
  [aCoder encodeObject:_location forKey:@"location"];
}

- (NSString *)itemArchivePath
{
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories firstObject];
  return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)isEqual:(id)object {
  EEMap *otherMap = (EEMap *)object;
  return [_mapKey isEqualToString:otherMap.mapKey];
}

- (NSUInteger)hash
{
  return [_mapKey hash];
}

@end
