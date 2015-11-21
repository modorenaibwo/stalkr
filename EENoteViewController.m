// Copyright 2004-present Facebook. All Rights Reserved.

#import "EENoteViewController.h"
#import "EEAnnotation.h"
#import "EEMap.h"
#import "EEMapStore.h"

@interface EENoteViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) EEMap *currentMap;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteScrollView;
@property (strong, nonatomic) EEAnnotation *currentAnnotation;

@end

@implementation EENoteViewController

- (IBAction)backgroundTapped:(id)sender
{
  [self.view endEditing:YES];
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Note";

    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:[self navigationController] action:@selector(saveNote:)];
    navItem.rightBarButtonItem = save;
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    navItem.leftBarButtonItem = cancel;
  }
  return self;
}

- (instancetype)initWithMap:(EEMap *)map location:(CLLocationCoordinate2D)currentLocation
{
  self = [self init];
  if (self) {
    _currentMap = map;
    _coordinate = currentLocation;
  }

  return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  if (_currentMap && [_noteScrollView.text isEqualToString:@""]) {
    _noteScrollView.delegate = self;
    _noteScrollView.textColor = [UIColor lightGrayColor];
    _noteScrollView.text = @"Enter contents of note here";
  }
}

- (instancetype)initWithAnnotation:(EEAnnotation *)annotation map:(EEMap *)map
{
  self = [self init];
  if (self) {
    _currentAnnotation = annotation;
    _currentMap = map;
    _coordinate = _currentAnnotation.coordinate;
    if (!_currentMap) {
      UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
      self.navigationItem.leftBarButtonItem = done;
      self.navigationItem.rightBarButtonItem = nil;
      [_noteScrollView setEditable:NO];
      _noteTitle.enabled = NO;
    }
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIGraphicsBeginImageContext(self.view.frame.size);
  [[UIImage imageNamed:@"table.jpg"] drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  self.view.backgroundColor = [UIColor colorWithPatternImage:image];

  if (!_currentMap) {
    [_noteScrollView setEditable:NO];
    [_noteTitle setUserInteractionEnabled:NO];
  }

  _noteScrollView.backgroundColor = [UIColor clearColor];
  [_noteScrollView.layer setBorderColor:[[UIColor grayColor] CGColor]];
  [_noteScrollView.layer setBorderWidth:2.0];
  _noteScrollView.layer.cornerRadius = 5;
  _noteScrollView.clipsToBounds = YES;

  [_noteTitle setText:_currentAnnotation.title];
  [_noteScrollView setText:_currentAnnotation.subtitle];
}

- (IBAction)saveNote:(id)sender
{
  if (!_currentAnnotation) {
    _currentAnnotation = [[EEAnnotation alloc] initWithTitle:_noteTitle.text Coordinate:_coordinate];
  }
  if ([_noteScrollView.text isEqualToString:@"Enter contents of note here"]) {
    _currentAnnotation.subtitle = @"";
  } else {
    _currentAnnotation.subtitle = _noteScrollView.text;
  }
  _currentAnnotation.title = _noteTitle.text;
  [[EEMapStore sharedStore] addAnnotation:_currentAnnotation forMap:_currentMap];
  if (![_noteTitle.text isEqualToString:@""]) {
    [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  if ([textView.text isEqualToString:@"Enter contents of note here"]) {
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
  }
  [textView becomeFirstResponder];
}

@end
