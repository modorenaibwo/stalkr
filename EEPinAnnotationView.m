//  Copyright 2004-present Facebook. All Rights Reserved.

#import "EEPinAnnotationView.h"

@implementation EEPinAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if (!(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		return nil;
	}
	[self setCanShowCallout:NO];
	[self setAnimatesDrop:YES];
	return self;
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
