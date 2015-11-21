// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class EEMap;

@interface EEStatsViewController : UIViewController

- (instancetype)initWithMap:(EEMap *)currentMap;
- (NSString *)formatTime:(int)seconds;

@end
