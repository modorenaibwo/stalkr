//
//  EECustomTableViewCell.m
//  MapJourney
//
//  Created by Ellen Pei Pei Wu on 8/11/14.
//  Copyright 2004-present Facebook. All Rights Reserved.
//

#import "EECustomTableViewCell.h"

#import "EEAnnotation.h"
#import "EEMap.h"

@implementation EECustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      _profilePicView = [[UIImageView alloc] init];
      _titleLabel = [[UILabel alloc] init];
      _titleLabel.textColor = [UIColor blackColor];
      _titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0];
      _authorLabel = [[UILabel alloc] init];
      _authorLabel.textColor = [UIColor blackColor];
      _authorLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
      _locationLabel = [[UILabel alloc] init];
      _locationLabel.textColor = [UIColor blackColor];
      _locationLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
      _annotationsLabel = [[UILabel alloc] init];
      _annotationsLabel.textColor = [UIColor blackColor];
      _annotationsLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
      _dateCreated = [[UILabel alloc] init];
      _dateCreated.textColor = [UIColor blackColor];
      _dateCreated.font = [UIFont fontWithName:@"Helvetica" size:12.0];
      _dateCreated.textAlignment = NSTextAlignmentRight;
      _annotationsButton = [[UIButton alloc] init];
    }
    return self;
}

- (IBAction)viewAnnotations:(id)sender
{
  [_delegate customTableViewCellDidTapButton:self];
}

- (void)setMapForCell:(EEMap *)map
{
  _currentMap = map;
  _titleLabel.text = map.mapTitle;
  if ([map.annotations count] > 0) {
    [_annotationsButton setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    [_annotationsButton addTarget:self action:@selector(viewAnnotations:) forControlEvents:UIControlEventTouchUpInside];
  }
  PFUser *user;
  if (map.sharedBy) {
    user = map.sharedBy;
  } else {
    user = [PFUser currentUser];
  }
  [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    PFFile *profilePicFile = [object objectForKey:@"profilePic"];
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      if (!error) {
        UIImage *image = [UIImage imageWithData:data];
        UIImage *mask = [UIImage imageNamed:@"mask"];
        UIImage *maskedImage = [self maskImage:image withMask:mask];
        _profilePicView.image = maskedImage;
      }
    }];
    _authorLabel.text = [NSString stringWithFormat:@"Author: %@", [object objectForKey:@"fullName"]];
  }];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mma"];
  NSString *dateCreated = [dateFormatter stringFromDate:map.dateCreated];
  _dateCreated.text = dateCreated;
  _locationLabel.text = map.location;
  NSArray *annotations = map.annotations;
  int noteCount = 0;
  int imageCount = 0;
  for (EEAnnotation *annotation in annotations) {
    if (annotation.image) {
      imageCount++;
    } else {
      noteCount++;
    }
  }
  NSString *annotationString = [[NSString alloc] initWithFormat:@"%d images, %d notes", imageCount, noteCount];
  _annotationsLabel.text = annotationString;
  [self setNeedsLayout];
  if ([_currentMap.annotations count] == 0) {
    _annotationsButton.hidden = YES;
  }
}

- (void)setAnnotationForCell:(EEAnnotation *)annotation
{
  _currentAnnotation = annotation;
  _titleLabel.text = annotation.title;
  if (annotation.image) {
    UIImage *mask = [UIImage imageNamed:@"mask"];
    UIImage *maskedImage = [self maskImage:annotation.image withMask:mask];
    _profilePicView.image = maskedImage;
    _authorLabel.text = [NSString stringWithFormat:@"Location: %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
  } else {
    _profilePicView.image = [UIImage imageNamed:@"notePlaceholder"];
    _authorLabel.text = annotation.subtitle;
  }
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.backgroundColor = [UIColor clearColor];
  _profilePicView.frame = CGRectMake(0, 0, 68, 68);
  if (_currentAnnotation) {
    _titleLabel.frame = CGRectMake(70, 18, self.frame.size.width-70, 19);
    _authorLabel.frame = CGRectMake(70, 37, self.frame.size.width-70, 13);
  } else if (_currentMap) {
    _titleLabel.frame = CGRectMake(70, 0, self.frame.size.width-70, 19);
    _authorLabel.frame = CGRectMake(70, 19, self.frame.size.width-70, 13);
    _locationLabel.frame = CGRectMake(70, 32, self.frame.size.width-70, 13);
    _annotationsLabel.frame = CGRectMake(70, 45, self.frame.size.width-70, 13);
    _dateCreated.frame = CGRectMake(70, 58, self.frame.size.width-75, 13);
    _annotationsButton.frame = CGRectMake(self.frame.size.width-50, 5, 45, 45);
    [self.contentView addSubview:_locationLabel];
    [self.contentView addSubview:_annotationsLabel];
    [self.contentView addSubview:_dateCreated];
    [self.contentView addSubview:_annotationsButton];
  }
  [self.contentView addSubview:_profilePicView];
  [self.contentView addSubview:_titleLabel];
  [self.contentView addSubview:_authorLabel];
}

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{

	CGImageRef maskRef = maskImage.CGImage;

	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                      CGImageGetHeight(maskRef),
                                      CGImageGetBitsPerComponent(maskRef),
                                      CGImageGetBitsPerPixel(maskRef),
                                      CGImageGetBytesPerRow(maskRef),
                                      CGImageGetDataProvider(maskRef), NULL, false);

	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
  UIImage *orientedImage= [[UIImage alloc] initWithCGImage: masked scale:1.0 orientation:image.imageOrientation];
  return orientedImage;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];
  _dateCreated.hidden = editing;
  _annotationsButton.hidden = editing;
}

@end
