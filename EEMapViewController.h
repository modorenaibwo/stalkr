// Copyright 2004-present Facebook. All Rights Reserved.

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class EEAnnotation;
@class EEMap;

@protocol EEMapViewControllerDelegate;

@interface EEMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, weak) id <EEMapViewControllerDelegate> delegate;

- (instancetype)initWithMap:(EEMap *)currentMap;

@end

@protocol EEMapViewControllerDelegate <NSObject>

- (void)mapViewControllerDidEndMap:(EEMapViewController *)mapViewController;

@end
