// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import <UIKit/UIKit.h>

@class EEMap;
@protocol EESavedMapViewControllerDelegate;

@interface EESavedMapViewController : UIViewController <MKMapViewDelegate, UINavigationControllerDelegate>
{
  NSString *_text;
}

@property (nonatomic, weak) id <EESavedMapViewControllerDelegate> delegate;

- (instancetype)initWithMap:(EEMap *)currentMap toUpload:(BOOL)upload atIndex:(NSIndexPath *)indexPath fromNotifiation:(BOOL)pushed;

@end

@protocol EESavedMapViewControllerDelegate <NSObject>

- (void)savedMapViewControllerDidDeleteRowAtIndexPath:(NSIndexPath *)indexPath;

@end
