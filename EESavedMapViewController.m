// Copyright 2004-present Facebook. All Rights Reserved.

#import "EESavedMapViewController.h"
#import "EEAnnotation.h"
#import "EEAnnotationView.h"
#import "EECommunications.h"
#import "EEDetailImageViewController.h"
#import "EEHomeViewController.h"
#import "EEMap.h"
#import "EEMapStore.h"
#import "EENoteViewController.h"
#import "EEPinAnnotationView.h"

@interface EESavedMapViewController () <MKMapViewDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, EEAnnotationViewDelegate, FBFriendPickerDelegate>

@property (nonatomic, strong) EEMap *currentMap;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPolylineView *lineView;
@property (strong, nonatomic) EEAnnotation *selectedAnnotation;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) FBFriendPickerViewController *fpvc;
@property (atomic, assign) BOOL upload;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *uploadingLabel;

@end

@implementation EESavedMapViewController

- (IBAction)setMapType:(UISegmentedControl *)sender
{
  switch (sender.selectedSegmentIndex) {
    case 0:
      _mapView.mapType = MKMapTypeStandard;
      break;
    case 1:
      _mapView.mapType = MKMapTypeSatellite;
      break;
    case 2:
      _mapView.mapType = MKMapTypeHybrid;
      break;
    default:
      break;
  }
}

- (instancetype)initWithMap:(EEMap *)currentMap toUpload:(BOOL)upload atIndex:(NSIndexPath *)indexPath fromNotifiation:(BOOL)pushed
{
  self = [super init];
  if (self) {
    _currentMap = currentMap;
    _upload = upload;
    _indexPath = indexPath;
    _shareButton.hidden = YES;
    if (upload) {
      [EECommunications uploadMap:_currentMap withCallback:^(BOOL succeeded) {
        if (succeeded) {
          [[EEMapStore sharedStore] addMap:_currentMap];
          _shareButton.hidden = NO;
          _uploadingLabel.hidden = YES;
        } else {
          [[[UIAlertView alloc] initWithTitle:@"Upload Failed"
                                      message:@"Failed to upload map. Please try again"
                                     delegate:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil] show];
        }
      }];
    }
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = _currentMap.mapTitle;
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(discardMap:)];
    navItem.rightBarButtonItem = bbi;
    navItem.hidesBackButton = YES;
    if (!upload && !pushed) {
      UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:[self navigationController] action:@selector(dismissModalViewControllerAnimated:)];
      navItem.leftBarButtonItem = doneButton;
    } else {
      UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleDone target:self action:@selector(home:)];
      navItem.leftBarButtonItem = back;
    }
  }
  return self;
}

- (IBAction)home:(id)sender
{
  NSArray *viewControllers = [self.navigationController viewControllers];
  for (id vc in viewControllers) {
    if ([vc isKindOfClass:[EEHomeViewController class]]) {
      [self.navigationController popToViewController:vc animated:YES];
      return;
    }
  }
  EEHomeViewController *hvc = [[EEHomeViewController alloc] init];
  [self.navigationController pushViewController:hvc animated:YES];
}

- (IBAction)discardMap:(id)sender
{
  UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to delete this map?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
  [confirmation show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    return;
  }
  if (buttonIndex == 1) {
    if ([alertView.title isEqualToString:@"Confirmation"]) {
      [[EEMapStore sharedStore] removeMap:_currentMap];
      [EECommunications deleteMap:_currentMap];
      _currentMap = nil;
      _lineView = nil;
      if (_upload) {
        [self home:self];
      } else {
        [_delegate savedMapViewControllerDidDeleteRowAtIndexPath:_indexPath];
        [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
      }
    }
    if ([alertView.title isEqualToString:@"Facebook"]) {
      UITextField *textField = [alertView textFieldAtIndex:0];
      if ([textField.text length] == 0) {
        return;
      }
      _text = textField.text;
      [EECommunications requestStatus:_text];
    }
  }
}

- (instancetype)init
{
  [NSException raise:@"Singleton" format:@"Must initialize with pre-existing map"];
  return nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  if (_indexPath || !_upload) {
    _shareButton.hidden = NO;
    _uploadingLabel.hidden = YES;
  }

  UIGraphicsBeginImageContext(self.view.frame.size);
  [[UIImage imageNamed:@"table.jpg"] drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  self.view.backgroundColor = [UIColor colorWithPatternImage:image];

  NSArray *pinLocations = _currentMap.annotations;
  int size = (int)[pinLocations count];
  for(int i = 0; i < size; i++) {
    EEAnnotation *currentAnnotation = pinLocations[i];
    [_mapView addAnnotation:currentAnnotation];
  }

  NSArray *points = [[EEMapStore sharedStore] allPointsForMap:_currentMap];
  NSInteger numberOfPoints = [points count];

  CLLocationDegrees maxLat = -90;
  CLLocationDegrees maxLon = -180;
  CLLocationDegrees minLat = 90;
  CLLocationDegrees minLon = 180;

  for (int i = 0; i < numberOfPoints; i++) {
    CLLocation* currentLocation = [points objectAtIndex:i];
    if(currentLocation.coordinate.latitude > maxLat)
      maxLat = currentLocation.coordinate.latitude;
    if(currentLocation.coordinate.latitude < minLat)
      minLat = currentLocation.coordinate.latitude;
    if(currentLocation.coordinate.longitude > maxLon)
      maxLon = currentLocation.coordinate.longitude;
    if(currentLocation.coordinate.longitude < minLon)
      minLon = currentLocation.coordinate.longitude;
  }

  MKCoordinateRegion region;
  region.center.latitude = (maxLat + minLat) / 2;
  region.center.longitude = (maxLon + minLon) / 2;
  region.span.latitudeDelta = (maxLat - minLat) * 1.1;
  region.span.longitudeDelta = (maxLon - minLon) * 1.1;
  if ([_currentMap.points count] > 0) {
    [_mapView setRegion:region];
  }

  CLLocationCoordinate2D coordinates[numberOfPoints];
  for(int i = 0; i < numberOfPoints; i++) {
    CLLocation *currentPoint = points[i];
    CLLocationCoordinate2D coordinate2 = currentPoint.coordinate;
    coordinates[i] = coordinate2;
  }
  MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:numberOfPoints];

  _lineView = [[MKPolylineView alloc]initWithPolyline:polyline];
  _lineView.strokeColor = [UIColor blueColor];
  _lineView.lineWidth = 5;

  [_mapView setDelegate:self];
  [_mapView addOverlay:polyline];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
  return _lineView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
  id <MKAnnotation> annotation = [view annotation];
  if ([annotation isKindOfClass:[EEAnnotation class]])
  {
    EENoteViewController *noteViewController = [[EENoteViewController alloc] initWithAnnotation:_selectedAnnotation map:nil];
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
    if(annotation.subtitle != nil) {
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
  EEDetailImageViewController *divc = [[EEDetailImageViewController alloc] initWithAnnotation:(EEAnnotation *)annotationView.currentAnnotation map:nil];
  UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:divc];
  modalNavController.delegate = self;
  [self presentViewController:modalNavController animated:YES completion:NULL];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
  for (UIView *subview in view.subviews ) {
    [subview removeFromSuperview];
  }
}

- (IBAction)shareMap:(id)sender
{
  _fpvc = [[FBFriendPickerViewController alloc] init];
  _fpvc.delegate = self;
  [self presentViewController:_fpvc animated:YES completion:NULL];
  _fpvc.title = @"Pick Friends";
  [_fpvc loadData];
  [_fpvc.doneButton setTarget:self];
  [_fpvc.doneButton setAction:@selector(done:)];
  [_fpvc.cancelButton setTarget:self];
  [_fpvc.cancelButton setAction:@selector(cancel:)];

}

- (IBAction)cancel:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)done:(id)sender
{
  [EECommunications checkMapExists:_currentMap withCallback:^(BOOL succeeded) {
    if (succeeded) {
      [EECommunications shareMap:_currentMap withFriends:_fpvc.selection withCallback:nil];
    }
  }];
  [EECommunications createGraphObject];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Enter text to post on timeline" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Post", nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  [alert show];
  [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
