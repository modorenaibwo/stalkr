// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol EELocationManagerDelegate;
@class EEMap;

@interface EELocationManager : NSObject

@property (nonatomic, weak) id <EELocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

- (instancetype)initWithMap:(EEMap *)map;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (CLLocation *)getCurrentLocation;
- (int)calculateTime;
- (NSString *)formatTime:(int)seconds;
- (void)setLocationForMap;

@end

@protocol EELocationManagerDelegate <NSObject>

- (void)didUpdateUserLocation:(EELocationManager *)locManager coordPoints:(CLLocationCoordinate2D *)coordinates count:(NSInteger)numberOfPoints loc:(CLLocation *)currentUserLocation;

@end
