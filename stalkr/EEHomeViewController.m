// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEHomeViewController.h"

#import "EEDetailImageViewController.h"
#import "EELocationManager.h"
#import "EELoginViewController.h"
#import "EEMap.h"
#import "EEMapStore.h"
#import "EEMapViewController.h"
#import "EEMapsTableViewController.h"
#import "EESavedMapViewController.h"

@interface EEHomeViewController () <EEMapViewControllerDelegate, EEMapsTableViewControllerDelegate>;

@property (strong, nonatomic) IBOutlet UIButton *startMapButton;
@property (strong, nonatomic) IBOutlet UIButton *continueMapButton;
@property (strong, nonatomic) EEMap *currentMap;
@property (strong, nonatomic) NSArray *allImages;
@property (strong, nonatomic) UIBarButtonItem *viewSavedMapsButtonItem;

@end

@implementation EEHomeViewController

- (instancetype)init
{
  self = [super init];
  if (self) {
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Home";
    _startMapButton = [[UIButton alloc] init];
    [_startMapButton setTitle:@"Begin!" forState:UIControlStateNormal];
    [_startMapButton addTarget:self action:@selector(startMap:) forControlEvents:UIControlEventTouchUpInside];
    _continueMapButton = [[UIButton alloc] init];
    [_continueMapButton setTitle:@"Continue" forState:UIControlStateNormal];
    [_continueMapButton addTarget:self action:@selector(continueMap:) forControlEvents:UIControlEventTouchUpInside];
    _viewSavedMapsButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(viewSavedMaps:)];
    navItem.rightBarButtonItem = _viewSavedMapsButtonItem;

    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutPressed:)];
    navItem.leftBarButtonItem = logoutButton;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:YES];
  self.navigationController.navigationBar.hidden = NO;
  [EECommunications getMapsWithCallback:^(BOOL succeeded) {
    if (succeeded) {
      if (_collectionView) {
        _allImages = [[EEMapStore sharedStore] allImages];
        [_collectionView reloadData];
      }
    }
  }];
  if(!_currentMap) {
    _continueMapButton.hidden = YES;
    _startMapButton.hidden = NO;
  } else if (_currentMap) {
    _startMapButton.hidden = YES;
    _continueMapButton.hidden = NO;
  }
  [_collectionView reloadData];
}

- (IBAction)logoutPressed:(id)sender
{
  [PFUser logOut];
  id rvc = [[self.navigationController viewControllers] objectAtIndex:0];
  if ([rvc isKindOfClass:[EELoginViewController class]]) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  } else {
    EELoginViewController *lvc = [[EELoginViewController alloc] init];
    [self.navigationController pushViewController:lvc animated:NO];
  }
}

- (IBAction)viewSavedMaps:(id)sender
{
  if ([[[EEMapStore sharedStore] allMaps] count]) {
    EEMapsTableViewController *mapsTable = [[EEMapsTableViewController alloc] init];
    mapsTable.delegate = self;
    [self.navigationController pushViewController:mapsTable animated:YES];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIGraphicsBeginImageContext(self.view.frame.size);
  [[UIImage imageNamed:@"homeView.jpg"] drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  self.view.backgroundColor = [UIColor colorWithPatternImage:image];

  _startMapButton.frame = CGRectMake(59, 470, 202, 44);
  _continueMapButton.frame = CGRectMake(59, 470, 202, 44);
  _startMapButton.backgroundColor = [UIColor lightGrayColor];
  _continueMapButton.backgroundColor = [UIColor lightGrayColor];
  [self.view addSubview:_startMapButton];
  [self.view addSubview:_continueMapButton];

  CALayer *startBtnLayer = [_startMapButton layer];
  [startBtnLayer setMasksToBounds:YES];
  [startBtnLayer setCornerRadius:10.0];

  CALayer *continueBtnLayer = [_continueMapButton layer];
  [continueBtnLayer setMasksToBounds:YES];
  [continueBtnLayer setCornerRadius:10.0];

  _flowLayout = [[UICollectionViewFlowLayout alloc] init];
  CGRect collectionFrame = CGRectMake(self.view.bounds.size.width*0.05, self.view.bounds.size.height*0.2,
                                      self.view.bounds.size.width*0.9, self.view.bounds.size.height*0.55);

  _collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:_flowLayout];
  _collectionView.bounces = YES;
  [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
  _collectionView.backgroundColor = [UIColor clearColor];
  _collectionView.dataSource = self;
  _collectionView.delegate = self;
  _collectionView.allowsSelection = NO;
  _collectionView.allowsMultipleSelection = NO;

  [_flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
  _flowLayout.minimumLineSpacing = 11.0;
  _flowLayout.sectionInset = UIEdgeInsetsMake(15, 5, 15, 5);
  _flowLayout.minimumInteritemSpacing = 11.0;
  _flowLayout.itemSize = CGSizeMake(85, 85);

  [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
  [self.view addSubview:_collectionView];

  // Width constraint
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:0.9
                                                         constant:0]];

  // Height constraint
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:0.55
                                                         constant:0]];

  // Center horizontally
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];

  // Center vertically
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:0.95
                                                         constant:0.0]];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

  if (_allImages && [_allImages count] > indexPath.row) {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = _allImages[indexPath.row];
    cell.backgroundView = imageView;
  }
  CGFloat redValue = (arc4random() % 255) / 255.0f;
  CGFloat greenValue = (arc4random() % 255) / 255.0f;
  CGFloat blueValue = (arc4random() % 255) / 255.0f;
  cell.backgroundColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:0.5f];

  return cell;
}

- (IBAction)startMap:(id)sender
{
  _currentMap = [[EEMap alloc] init];
  EELocationManager *locManager = [[EELocationManager alloc] initWithMap:_currentMap];
  _currentMap.customLocationManager = locManager;
  EEMapViewController *mapViewController = [[EEMapViewController alloc] initWithMap:_currentMap];
  mapViewController.delegate = self;
  [self.navigationController pushViewController:mapViewController animated:YES];
}

- (IBAction)continueMap:(id)sender
{
  EEMapViewController *mapViewController = [[EEMapViewController alloc] initWithMap:_currentMap];
  mapViewController.delegate = self;
  [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)mapViewControllerDidEndMap:(EEMapViewController *)mapViewController {
  _currentMap = nil;
}

- (void)mapsTableViewDidRemoveCurrentMap:(EEMapsTableViewController *)mtvc {
  _currentMap = nil;
}

@end
