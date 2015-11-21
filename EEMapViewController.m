// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEMapViewController.h"
#import "EEAnnotation.h"
#import "EEAnnotationView.h"
#import "EECommunications.h"
#import "EEDetailImageViewController.h"
#import "EEHomeViewController.h"
#import "EELocationManager.h"
#import "EEMap.h"
#import "EEMapStore.h"
#import "EENoteViewController.h"
#import "EEPinAnnotationView.h"
#import "EESavedMapViewController.h"
#import "EEStatsViewController.h"

@interface EEMapViewController () <MKMapViewDelegate, EELocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, EEAnnotationViewDelegate, EEDetailImageViewDelegate>;

@property (weak, nonatomic) IBOutlet UIButton *addNoteButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) EELocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *zoomFitButton;
@property (strong, nonatomic) EEMap *currentMap;
@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) MKPolylineView *lineView;
@property (strong, nonatomic) UIImage *currentImage;
@property (nonatomic, strong) UIPopoverController *imagePickerPopover;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *currentPinLocation;
@property (strong, nonatomic) EEAnnotation *selectedAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation EEMapViewController

- (instancetype)initWithMap:(EEMap *)currentMap
{
  self = [super init];
  if (self) {
    _currentMap = currentMap;
    _locationManager = currentMap.customLocationManager;
    _locationManager.delegate = self;
    _currentLocation = _locationManager.currentLocation;

    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;

    UIBarButtonItem *stats = [[UIBarButtonItem alloc] initWithTitle:@"Stats" style:UIBarButtonItemStyleDone target:self action:@selector(showStats:)];
    self.navigationItem.rightBarButtonItem = stats;
    self.navigationItem.title = @"Map in progress";

  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _mapView.showsUserLocation = YES;
  _mapView.userTrackingMode = YES;

  if (!_currentLocation) {
    _startButton.hidden = NO;
    _stopButton.hidden = YES;
    _cameraButton.hidden = YES;
    _addNoteButton.hidden = YES;
    _zoomFitButton.hidden = YES;
  } else {
    _startButton.hidden = YES;
    _stopButton.hidden = NO;
    _cameraButton.hidden = NO;
    _addNoteButton.hidden = NO;
    _zoomFitButton.hidden = NO;
  }

  MKUserLocation *userLocation = _mapView.userLocation;
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (userLocation.location.coordinate, 100, 100);
  [_mapView setRegion:region animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:YES];
  [self displayAnnotations];

  _mapView.showsUserLocation = YES;
  _mapView.userTrackingMode = YES;
}

- (void)displayAnnotations
{
  NSSet *annotationSet = [_mapView annotationsInMapRect:_mapView.visibleMapRect];
  NSArray *pinLocations = _currentMap.annotations;
  int size = (int)[pinLocations count];
  for(int i = 0; i < size; i++) {
    EEAnnotation *currentAnnotation = pinLocations[i];
    if(![annotationSet containsObject:currentAnnotation]) {
      [_mapView addAnnotation:currentAnnotation];
    }
  }
}

- (IBAction)zoomToFit:(id)sender
{
  if (_currentLocation) {
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = YES;
    [_mapView setCenterCoordinate:_currentLocation.coordinate animated:YES];
  }
}

- (IBAction)showStats:(id)sender
{
  if (_currentLocation) {
    EEStatsViewController *statsViewController = [[EEStatsViewController alloc] initWithMap:_currentMap];
    [self.navigationController pushViewController:statsViewController animated:YES];
  }
}

- (IBAction)setMapType:(UISegmentedControl *)sender
{
  switch (sender.selectedSegmentIndex) {
    case 0:
      _mapView.mapType = MKMapTypeStandard;
      break;
    case 1:
      _mapView.mapType = MKMapTypeSatellite;
      _zoomFitButton.backgroundColor = [UIColor whiteColor];
      break;
    case 2:
      _mapView.mapType = MKMapTypeHybrid;
      _zoomFitButton.backgroundColor = [UIColor whiteColor];
      break;
    default:
      break;
  }
}

- (IBAction)pressedStart:(id)sender
{
  _startButton.hidden = YES;
  _stopButton.hidden = NO;
  _cameraButton.hidden = NO;
  _addNoteButton.hidden = NO;
  _zoomFitButton.hidden = NO;
  [_mapView setUserTrackingMode:MKUserTrackingModeFollow];
  [_locationManager startUpdatingLocation];
  [self.view setNeedsDisplay];
}

- (IBAction)pressedStop:(id)sender
{
  if (_currentLocation) {
    [_locationManager setLocationForMap];
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Tracking has ended" message:@"Your map has been saved, please enter a name for the map:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField =  [prompt textFieldAtIndex: 0];
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [textField setPlaceholder:@"Name for map"];
    textField.keyboardAppearance = UIKeyboardTypeDefault;
    [textField becomeFirstResponder];
    [prompt show];
  }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
  UITextField *textField = [alertView textFieldAtIndex:0];
  if ([textField.text length] == 0) {
    return NO;
  }
  if ([alertView.title isEqualToString:@"Tracking has ended"]) {
    _currentMap.mapTitle = textField.text;
  }

  return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if ([alertView.title isEqualToString:@"Tracking has ended"]) {
    if (buttonIndex == 0) {
      return;
    }
    [_mapView setUserTrackingMode:MKUserTrackingModeNone];
    [_locationManager stopUpdatingLocation];
    EESavedMapViewController *savedMap = [[EESavedMapViewController alloc] initWithMap:_currentMap toUpload:YES atIndex:nil fromNotifiation:NO];
    [_delegate mapViewControllerDidEndMap:self];
    _currentMap = nil;
    _currentLocation = nil;
    _locationManager.currentLocation = nil;
    [self.navigationController pushViewController:savedMap animated:YES];
  }
  else if ([alertView.title isEqualToString:@"Name your picture"]) {
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (buttonIndex == 0) {
      return;
    }
    EEAnnotation *pictureAnnotation = [[EEAnnotation alloc] initWithTitle:textField.text Coordinate:_currentPinLocation.coordinate];

    NSData *imageData = UIImageJPEGRepresentation(_currentImage, 0.2f);
    pictureAnnotation.image = [UIImage imageWithData:imageData];
    [[EEMapStore sharedStore] addAnnotation:pictureAnnotation forMap:_currentMap];
    [self displayAnnotations];
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (succeeded) {
        pictureAnnotation.imageURL = imageFile.url;
      }
    }];

  }
}

- (void)didUpdateUserLocation:(EELocationManager *)locManager coordPoints:(CLLocationCoordinate2D *)coordinates count:(NSInteger)numberOfPoints loc:(CLLocation *)currentUserLocation
{
  _currentLocation = currentUserLocation;
  int seconds = [_locationManager calculateTime];
  _timeLabel.text = [_locationManager formatTime:seconds];

  MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:numberOfPoints];
  dispatch_async(dispatch_get_main_queue(), ^{
    [_mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
  });
  _routeLine = polyline;

  _lineView = [[MKPolylineView alloc]initWithPolyline:_routeLine];
  _lineView.strokeColor = [UIColor blueColor];
  _lineView.lineWidth = 5;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
  return _lineView;
}

- (IBAction)takePicture:(id)sender
{
  if (!_currentLocation) {
    return;
  }
  if([_imagePickerPopover isPopoverVisible]) {
    [_imagePickerPopover dismissPopoverAnimated:YES];
    _imagePickerPopover = nil;
    return;
  }

  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.allowsEditing = YES;

  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  } else {
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  }
  imagePicker.delegate = self;
  [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  _currentImage = info[UIImagePickerControllerOriginalImage];

  NSMutableDictionary *imageMetadata = [[info objectForKey:UIImagePickerControllerMediaMetadata]mutableCopy];
  _currentPinLocation = _currentLocation;
  if(_currentPinLocation) {
    [imageMetadata setObject:[self gpsDictionaryForLocation:_currentPinLocation] forKey:(NSString*)kCGImagePropertyGPSDictionary];
  }

  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
  ^(NSURL *newURL, NSError *error) {
    if(error) {
      NSLog(@"Error writing image with metadata to Photo Library: %@", error);
    } else {
      NSLog(@"Wrote image with metadata to Photo Library");
    }
  };

  [library writeImageToSavedPhotosAlbum:[_currentImage CGImage] metadata:imageMetadata completionBlock:imageWriteCompletionBlock];

  NSNumber *longitude = imageMetadata[@"{GPS}"][@"Longitude"];
  NSNumber *latitude = imageMetadata[@"{GPS}"][@"Latitude"];
  if (longitude && latitude) {
    UIAlertView *pictureTitle = [[UIAlertView alloc] initWithTitle:@"Name your picture" message:@"Please enter a name for your picture" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    pictureTitle.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField =  [pictureTitle textFieldAtIndex: 0];
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [textField setPlaceholder:@"Name for image"];
    textField.keyboardAppearance = UIKeyboardTypeDefault;
    [textField becomeFirstResponder];
    [pictureTitle show];
  }

  if (_imagePickerPopover) {
    [_imagePickerPopover dismissPopoverAnimated:YES];
    _imagePickerPopover = nil;
  } else {
    [self dismissViewControllerAnimated:YES completion:NULL];
  }
}

- (NSDictionary *)gpsDictionaryForLocation:(CLLocation *)location
{
  CLLocationDegrees exifLatitude  = location.coordinate.latitude;
  CLLocationDegrees exifLongitude = location.coordinate.longitude;

  NSString * latRef;
  NSString * longRef;
  if (exifLatitude < 0.0) {
    latRef = @"S";
  } else {
    latRef = @"N";
  }

  if (exifLongitude < 0.0) {
    longRef = @"W";
  } else {
    longRef = @"E";
  }

  NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
  [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
  [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
  [locDict setObject:@(exifLatitude) forKey:(NSString *)kCGImagePropertyGPSLatitude];
  [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
  [locDict setObject:@(exifLongitude) forKey:(NSString *)kCGImagePropertyGPSLongitude];
  [locDict setObject:@(location.horizontalAccuracy) forKey:(NSString*)kCGImagePropertyGPSDOP];
  [locDict setObject:@(location.altitude) forKey:(NSString*)kCGImagePropertyGPSAltitude];

  return locDict;

}

- (void)save:(id)sender
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:_dismissBlock];
}

- (void)cancel:(id)sender
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:_dismissBlock];
}

- (IBAction)takeNote:(id)sender
{
  if (_currentLocation) {
    _currentPinLocation = _currentLocation;
    EENoteViewController *noteViewController = [[EENoteViewController alloc] initWithMap:_currentMap location:_currentPinLocation.coordinate];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    navController.delegate = self;
    [self presentViewController:navController animated:YES completion:NULL];
  }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
  _imagePickerPopover = nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
  id <MKAnnotation> annotation = [view annotation];
  if ([annotation isKindOfClass:[EEAnnotation class]] && annotation.subtitle != nil) {
    EENoteViewController *noteViewController = [[EENoteViewController alloc] initWithAnnotation:_selectedAnnotation map:_currentMap];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    navController.delegate = self;
    [self presentViewController:navController animated:YES completion:NULL];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(EEAnnotation *)annotation
{
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  _selectedAnnotation = annotation;
  static NSString *noteReuseID = @"EENoteAnnotation";
  static NSString *imageReuseID = @"EEImageAnnotation";
  if ([annotation isKindOfClass:[EEAnnotation class]]) {
    if(annotation.image == nil) {
      MKPinAnnotationView *pinView =
      (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:noteReuseID];
      if (pinView == nil) {
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:noteReuseID];
        customPinView.pinColor = MKPinAnnotationColorPurple;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        return customPinView;
      } else {
        pinView.annotation = annotation;
      }
      return pinView;
    } else {
      EEPinAnnotationView *pinView =
      (EEPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:imageReuseID];
      if (pinView == nil) {
        EEPinAnnotationView *customPinView = [[EEPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:imageReuseID];
        customPinView.pinColor = MKPinAnnotationColorGreen;
        return customPinView;
      } else {
        pinView.annotation = annotation;
      }
      return pinView;
    }
  }
  return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
  if (view.annotation.subtitle == nil && [view.annotation isKindOfClass:[EEAnnotation class]]) {
    EEAnnotationView *annotationView = [[EEAnnotationView alloc]initWithAnnotation:(EEAnnotation *)view.annotation reuseIdentifier:@"EEImageAnnotation"];
    [view addSubview:annotationView];
    annotationView.delegate = self;
  }
}

- (void)annotationViewDidTapButton:(EEAnnotationView *)annotationView
{
  EEDetailImageViewController *divc = [[EEDetailImageViewController alloc] initWithAnnotation:(EEAnnotation *)annotationView.currentAnnotation map:_currentMap];
  divc.delegate = self;
  [self.navigationController pushViewController:divc animated:YES];
}

- (void)didDeleteAnnotationFromMap:(EEAnnotation *)annotation
{
  [_mapView removeAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
  for (UIView *subview in view.subviews ){
    [subview removeFromSuperview];
  }
}

@end
