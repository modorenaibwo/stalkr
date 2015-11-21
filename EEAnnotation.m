// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEAnnotation.h"

@interface EEAnnotation () <NSCopying>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation EEAnnotation

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    _title = [aDecoder decodeObjectForKey:@"title"];
    _subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
    _coordinate.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
    _coordinate.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
    _imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_title forKey:@"title"];
  [aCoder encodeObject:_subtitle forKey:@"subtitle"];
  [aCoder encodeDouble:_coordinate.latitude forKey:@"latitude"];
  [aCoder encodeDouble:_coordinate.longitude forKey:@"longitude"];
  [aCoder encodeObject:_imageURL forKey:@"imageURL"];
}

- (id) initWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate
{
  self = [super init];
  if (self) {
    _title = title;
    _coordinate = coordinate;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  EEAnnotation *copy = [[[self class] allocWithZone:zone] init];
  [copy setTitle:_title];
  [copy setSubtitle:_subtitle];
  [copy setImageURL:_imageURL];
  copy.coordinate = _coordinate;
  return copy;
}

- (BOOL)isEqual:(EEAnnotation *)object
{
  return ((object.coordinate.latitude == _coordinate.latitude) && (object.coordinate.longitude == _coordinate.longitude));
}

- (NSUInteger)hash
{
  return [@( _coordinate.latitude) hash] + [@( _coordinate.longitude) hash];
}

@end
