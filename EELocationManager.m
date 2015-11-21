// Copyright 2004-present Facebook. All Rights Reserved.

#import "EELocationManager.h"

#import "EEMap.h"
#import "EEMapStore.h"

@interface EELocationManager () <CLLocationManagerDelegate>;

@property (nonatomic, weak) EEMap *currentMap;

@end

@implementation EELocationManager

- (instancetype)initWithMap:(EEMap *)map
{
  self = [super init];
  if (self) {
    _currentMap = map;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.pausesLocationUpdatesAutomatically = YES;
    [_locationManager setDistanceFilter:kCLDistanceFilterNone];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];

  }
  return self;
}

- (void)startUpdatingLocation
{
  [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
  [_locationManager stopUpdatingLocation];
}

- (CLLocation *)getCurrentLocation
{
  return [_currentLocation copy];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [errorAlert show];
  NSLog(@"Error: %@", error.description);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  _currentLocation = [locations lastObject];

  [[EEMapStore sharedStore] addLocation:_currentLocation forMap:_currentMap];
  NSArray *points = [[EEMapStore sharedStore] allPointsForMap:_currentMap];
  NSInteger numberOfPoints = [points count];
  CLLocationCoordinate2D coordinates[numberOfPoints];
  for (int i = 0; i < numberOfPoints; i++) {
    CLLocation *currentPoint = points[i];
    CLLocationCoordinate2D locationCoordinate = currentPoint.coordinate;
    coordinates[i] = locationCoordinate;
  }
  [_delegate didUpdateUserLocation:self coordPoints:coordinates count:numberOfPoints loc:_currentLocation];
}

- (int)calculateTime
{
  NSInteger count = _currentMap.points.count;
  CLLocation *lastPoint = _currentMap.points[count-1];
  CLLocation *firstPoint = _currentMap.points[0];

  int time = [lastPoint.timestamp timeIntervalSinceDate:firstPoint.timestamp];

  return time;
}

- (NSString *)formatTime:(int)seconds
{
  int sec = seconds % 60;
  int minutes = (seconds / 60) % 60;
  int hours = seconds / 3600;

  return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, sec];
}

- (void)setLocationForMap {
  CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
  [geoCoder reverseGeocodeLocation:_currentMap.points[0] completionHandler:^(NSArray *placemarks, NSError *error) {
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    _currentMap.location = [NSString stringWithFormat:@"%@, %@", [placemark locality], [placemark administrativeArea]];
  }];
}

@end
