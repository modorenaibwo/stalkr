// Copyright 2004-present Facebook. All Rights Reserved.

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class EEAnnotation;
@protocol EEDetailImageViewDelegate;

@interface EEDetailImageViewController : UIViewController

@property (nonatomic, weak) id <EEDetailImageViewDelegate> delegate;

- (instancetype)initWithAnnotation:(EEAnnotation *)annotation map:(EEMap *)currentMap;

@end

@protocol EEDetailImageViewDelegate <NSObject>

- (void)didDeleteAnnotationFromMap:(EEAnnotation *)annotation;

@end
