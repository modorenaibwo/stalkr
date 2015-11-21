// Copyright 2004-present Facebook. All Rights Reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class EEAnnotation;
@protocol EEAnnotationViewDelegate;

@interface EEAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIButton *thumbnailButton;
@property (strong, nonatomic) EEAnnotation *currentAnnotation;
@property (nonatomic, weak) id <EEAnnotationViewDelegate> delegate;

- (instancetype)initWithAnnotation:(EEAnnotation *)annotation reuseIdentifier:(NSString *)reuseId;

@end

@protocol EEAnnotationViewDelegate <NSObject>

- (void)annotationViewDidTapButton:(EEAnnotationView *)annotationView;

@end
