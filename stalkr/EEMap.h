// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class EELocationManager;

@interface EEMap : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, copy) NSString *mapKey;
@property (nonatomic, copy) NSString *mapTitle;
@property (nonatomic, copy) NSMutableArray *points;
@property (nonatomic, copy) NSMutableArray *annotations;
@property (nonatomic, strong) EELocationManager *customLocationManager;
@property (nonatomic, strong) PFObject *mapObject;
@property (nonatomic, strong) PFObject *sharedProperty;
@property (nonatomic, strong) PFUser *sharedBy;
@property (nonatomic, copy) NSString *location;

@end
