// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class EEMap;
@class EEAnnotation;

@interface EENoteViewController : UIViewController

- (instancetype)initWithMap:(EEMap *)map location:(CLLocationCoordinate2D)currentLocation;
- (instancetype)initWithAnnotation:(EEAnnotation *)annotation map:(EEMap *)map;

@end
