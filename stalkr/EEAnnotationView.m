// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEAnnotationView.h"

#import "EEAnnotation.h"
#import "EEDetailImageViewController.h"
#import "EEMap.h"

static CGFloat kMaxViewWidth = 150.0;

static CGFloat kViewWidth = 90;
static CGFloat kViewLength = 100;

static CGFloat kLeftMargin = 15.0;
static CGFloat kRightMargin = 5.0;
static CGFloat kTopMargin = 5.0;
static CGFloat kBottomMargin = 10.0;
static CGFloat kRoundBoxLeft = 10.0;

@interface EEAnnotationView () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>;

@property (nonatomic, strong) UILabel *imageLabel;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;

@end

@implementation EEAnnotationView

- (instancetype)initWithAnnotation:(EEAnnotation *)annotation reuseIdentifier:(NSString *)reuseId
{
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseId];
  if (self) {
    _currentAnnotation = annotation;

    self.backgroundColor = [UIColor clearColor];
    self.centerOffset = CGPointMake(50.0, 50.0);

    _imageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _imageLabel.font = [UIFont systemFontOfSize:9.0];
    _imageLabel.textColor = [UIColor whiteColor];
    _imageLabel.text = _currentAnnotation.title;
    _imageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _imageLabel.backgroundColor = [UIColor clearColor];

    _thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _thumbnailButton.contentMode = UIViewContentModeScaleAspectFit;
    [_thumbnailButton setUserInteractionEnabled:YES];
    [_thumbnailButton addTarget:self action:@selector(tappedThumbnail:) forControlEvents:UIControlEventTouchUpInside];
    if (!_currentAnnotation.image) {
      [EECommunications requestImageForAnnotation:_currentAnnotation withCallback:^(BOOL succeeded) {
        if (succeeded) {
          [_thumbnailButton setImage:_currentAnnotation.image forState:UIControlStateNormal];
        } else {
          NSLog(@"Failed to retrieve image");
        }
      }];
    } else {
      [_thumbnailButton setImage:_currentAnnotation.image forState:UIControlStateNormal];
    }
    [self addSubview:_imageLabel];
    [self addSubview:_thumbnailButton];
  }
  return self;
}

- (IBAction)tappedThumbnail:(id)sender
{
  [_delegate annotationViewDidTapButton:self];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  [_imageLabel sizeToFit];

  CGFloat optimumWidth = _imageLabel.frame.size.width + kRightMargin + kLeftMargin;
  CGRect frame = self.frame;
  if(optimumWidth < kViewWidth) {
    frame.size = CGSizeMake(kViewWidth, kViewLength);
  } else if (optimumWidth > kViewWidth) {
    frame.size = CGSizeMake(kMaxViewWidth, kViewLength);
  } else {
    frame.size = CGSizeMake(optimumWidth, kViewLength);
  }
  self.frame = frame;

  CGRect newFrame = _imageLabel.frame;
  newFrame.origin.x = kLeftMargin;
  newFrame.origin.y = kTopMargin;
  newFrame.size.width = self.frame.size.width - kRightMargin - kLeftMargin;
  _imageLabel.frame = newFrame;

  _thumbnailButton.frame = CGRectMake(kLeftMargin, _imageLabel.frame.origin.y + _imageLabel.frame.size.height + kTopMargin, self.frame.size.width - kRightMargin - kLeftMargin, self.frame.size.height - _imageLabel.frame.size.height - kTopMargin*2 - kBottomMargin);
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  if (_currentAnnotation != nil) {
    [[UIColor lightGrayColor] setFill];

    UIBezierPath *pointShape = [UIBezierPath bezierPath];
    [pointShape moveToPoint:CGPointMake(14.0, 0.0)];
    [pointShape addLineToPoint:CGPointMake(0.0, 0.0)];
    [pointShape addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [pointShape fill];

    UIBezierPath *roundedRect =
    [UIBezierPath bezierPathWithRoundedRect:
     CGRectMake(kRoundBoxLeft, 0.0, self.frame.size.width - kRoundBoxLeft, self.frame.size.height) cornerRadius:3.0];
    roundedRect.lineWidth = 2.0;
    [roundedRect fill];
  }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
  UIView* hitView = [super hitTest:point withEvent:event];
  if (hitView != nil) {
    [self.superview bringSubviewToFront:self];
  }
  return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
  CGRect rect = self.bounds;
  BOOL isInside = CGRectContainsPoint(rect, point);
  if(!isInside) {
    for (UIView *view in self.subviews) {
      isInside = CGRectContainsPoint(view.frame, point);
      if(isInside)
        break;
    }
  }
  return isInside;
}

@end
