//  Copyright 2004-present Facebook. All Rights Reserved.

#import "EEDetailImageViewController.h"

#import "EEAnnotation.h"
#import "EEMap.h"
#import "EEMapStore.h"

@interface EEDetailImageViewController () <UINavigationControllerDelegate>;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) EEAnnotation *currentAnnotation;
@property (nonatomic, copy) EEMap *currentMap;

@end

@implementation EEDetailImageViewController

- (instancetype)initWithAnnotation:(EEAnnotation *)annotation map:(EEMap *)currentMap
{
  self = [super init];
  if (self) {
    _currentAnnotation = annotation;
    _currentMap = currentMap;

    if (!currentMap) {
      UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:[self navigationController] action:@selector(dismissModalViewControllerAnimated:)];
      self.navigationItem.leftBarButtonItem = doneButton;
    }

    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePin:)];
    if (currentMap) {
      self.navigationItem.rightBarButtonItem = deleteButton;
    }
  }
  return self;
}

- (IBAction)deletePin:(id)sender
{
  _currentAnnotation.imageURL = nil;
  _currentAnnotation.image = nil;
  [[EEMapStore sharedStore] removeAnnotation:_currentAnnotation forMap:_currentMap];
  [_delegate didDeleteAnnotationFromMap:_currentAnnotation];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  _imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
  _imageView.contentMode = UIViewContentModeScaleAspectFit;
  _imageView.image = _currentAnnotation.image;
  [self.view addSubview:_imageView];

  UIGraphicsBeginImageContext(self.view.frame.size);
  [[UIImage imageNamed:@"table.jpg"] drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

@end
