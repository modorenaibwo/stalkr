// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEStatsViewController.h"
#import "EEMapViewController.h"
#import "EEMap.h"
#import "EEMapStore.h"

@interface EEStatsViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UILabel *avgRate;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UISegmentedControl *convertStats;
@property (weak, nonatomic) IBOutlet UILabel *course;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *altitude;
@property (weak, nonatomic) IBOutlet UILabel *longtitude;
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) NSArray *points;
@property (nonatomic, copy) EEMap *map;

@end

@implementation EEStatsViewController


- (instancetype)initWithMap:(EEMap *)currentMap
{
  self = [super init];
  if (self) {
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Statistics";
    _map = currentMap;
    _points = _map.points;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  [_locationManager startUpdatingLocation];
  
  _locationManager.delegate = self;
  _currentLocation = [[CLLocation alloc] init];
  
  UIGraphicsBeginImageContext(self.view.frame.size);
  [[UIImage imageNamed:@"stats.jpg"] drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  _currentLocation = locations.lastObject;
  
  float meters2feet = 3.28084;
  float convert2mph = 2.23694;
  float ms2kmhr = 3.6;
  float m2km = 0.001;
  float m2mi = 0.000621371;
  float s2hr = 0.000277778;
  
  float distance = [self calculateDistance];
  float miles = distance*m2mi;
  float km = distance*m2km;
  float time = [self calculateTime];
  float hour = time*s2hr;
  
  switch (_convertStats.selectedSegmentIndex) {
    case 0:
      _latitude.text = [[NSString stringWithFormat:@"%0.4f", _currentLocation.coordinate.latitude] stringByAppendingString:@"°"];
      _longtitude.text = [[NSString stringWithFormat:@"%0.4f", _currentLocation.coordinate.longitude] stringByAppendingString:@"°"];
      _altitude.text = [[NSString stringWithFormat:@"%0.4f", _currentLocation.altitude*meters2feet] stringByAppendingString:@" ft"];
      _speed.text = [[NSString stringWithFormat:@"%0.2f", _currentLocation.speed*convert2mph] stringByAppendingString:@" mph"];
      _course.text = [[NSString stringWithFormat:@"%0.2f", _currentLocation.course] stringByAppendingString:@"°"];
      _distance.text = [[NSString stringWithFormat:@"%0.2f", miles] stringByAppendingString:@" mi"];
      _totalTime.text = [self formatTime:time];
      _avgRate.text = [[NSString stringWithFormat:@"%0.2f", miles/hour] stringByAppendingString:@" mph"];
      break;
    case 1:
      _latitude.text = [[NSString stringWithFormat:@"%0.4f", _currentLocation.coordinate.latitude] stringByAppendingString:@"°"];
      _longtitude.text = [[NSString stringWithFormat:@"%0.4f", _currentLocation.coordinate.longitude] stringByAppendingString:@"°"];
      _altitude.text = [[NSString stringWithFormat:@"%0.4f", _currentLocation.altitude] stringByAppendingString:@" m"];
      _speed.text = [[NSString stringWithFormat:@"%0.2f", _currentLocation.speed*ms2kmhr] stringByAppendingString:@" km/h"];
      _course.text = [[NSString stringWithFormat:@"%0.2f", _currentLocation.course] stringByAppendingString:@"°"];
      _distance.text = [[NSString stringWithFormat:@"%0.2f", km] stringByAppendingString:@" km"];
      _totalTime.text = [self formatTime:time];
      _avgRate.text = [[NSString stringWithFormat:@"%0.2f", km/hour] stringByAppendingString:@" km/h"];
      break;
    default:
      break;
  }
}

- (double)calculateDistance
{
  double distance;
  NSInteger count = _points.count;
  
  for (int i = 0; i < count-1; i++) {
    distance += [_points[i+1] distanceFromLocation:_points[i]];
  }
  return distance;
}

- (int)calculateTime
{
  NSInteger count = _points.count;
  CLLocation *lastPoint = _points[count-1];
  CLLocation *firstPoint = _points[0];
  
  int time = [lastPoint.timestamp timeIntervalSinceDate:firstPoint.timestamp];
  
  return time;
}

- (NSString *)formatTime:(int)seconds
{
  int sec = seconds % 60;
  int minutes = (seconds / 60) % 60;
  int hours = seconds / 3600;
  
  return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, sec];
}

@end

