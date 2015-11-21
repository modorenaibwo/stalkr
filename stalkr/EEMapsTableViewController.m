// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEMapsTableViewController.h"

#import "EEAnnotation.h"
#import "EEAnnotationsTableViewController.h"
#import "EECustomTableViewCell.h"
#import "EEMap.h"
#import "EEMapStore.h"
#import "EESavedMapViewController.h"

@interface EEMapsTableViewController () <UINavigationControllerDelegate, EESavedMapViewControllerDelegate, EECustomTableViewCellDelegate>;

@property (nonatomic, copy) NSArray *allMaps;

@end

@implementation EEMapsTableViewController

- (instancetype)init
{
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Your Saved Maps";

    NSMutableArray *sharedMaps = [[NSMutableArray alloc] init];
    NSMutableArray *privateMaps = [[NSMutableArray alloc] init];
    NSArray *allMaps = [[EEMapStore sharedStore] allMaps];
    for(EEMap *map in allMaps) {
      if (!map.sharedBy) {
        [privateMaps addObject:map];
      } else {
        [sharedMaps addObject:map];
      }
    }
    _allMaps = @[privateMaps, sharedMaps];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table.jpg"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [_allMaps count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSMutableArray *maps = [_allMaps objectAtIndex:section];
  return [maps count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"Your Maps";
  } else {
    return @"Your Friends' Maps";
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"CellIdentifier";
  EECustomTableViewCell *cell = (EECustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[EECustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  cell.delegate = self;
  NSArray *maps = [_allMaps objectAtIndex:[indexPath section]];
  if ([maps count] > 0) {
    EEMap *currentMap = maps[indexPath.row];
    [cell setMapForCell:currentMap];
  }
  return cell;
}

- (void)customTableViewCellDidTapButton:(EECustomTableViewCell *)cell {
  EEAnnotationsTableViewController *atvc = [[EEAnnotationsTableViewController alloc] initWithMap:cell.currentMap];
  [self.navigationController pushViewController:atvc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {

    NSMutableArray *maps = [_allMaps objectAtIndex:[indexPath section]];
    EEMap *currentMap = maps[indexPath.row];
    if (!currentMap.mapTitle) {
      [_delegate mapsTableViewDidRemoveCurrentMap:self];
    }
    [[EEMapStore sharedStore] removeMap:currentMap];
    [EECommunications deleteMap:currentMap];
    [maps removeObject:currentMap];

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *maps = [_allMaps objectAtIndex:[indexPath section]];
  EEMap *currentMap = maps[indexPath.row];
  EESavedMapViewController *savedMapViewController = [[EESavedMapViewController alloc] initWithMap:currentMap toUpload:NO atIndex:indexPath fromNotifiation:NO];
  savedMapViewController.delegate = self;
  [savedMapViewController setTitle:currentMap.mapTitle];
  UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:savedMapViewController];
  modalNavController.delegate = self;
  [self presentViewController:modalNavController animated:YES completion:NULL];
}

- (void)savedMapViewControllerDidDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
  [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 71.0;
}

@end
