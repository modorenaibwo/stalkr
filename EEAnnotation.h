// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EEAnnotation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, retain) UIImage *image;

- (id)initWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate;

@end
