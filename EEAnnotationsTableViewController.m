// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEAnnotationsTableViewController.h"

#import "EEAnnotation.h"
#import "EECustomTableViewCell.h"
#import "EEDetailImageViewController.h"
#import "EEMap.h"
#import "EENoteViewController.h"

@interface EEAnnotationsTableViewController () <UINavigationControllerDelegate>

@property (nonatomic, copy) NSArray *annotations;

@end

@implementation EEAnnotationsTableViewController

- (instancetype)initWithMap:(EEMap *)map
{
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    for(EEAnnotation *annotation in map.annotations) {
      if (!annotation.image) {
        [notes addObject:annotation];
      } else {
        [images addObject:annotation];
      }
    }
    _annotations = @[images, notes];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table.jpg"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [_annotations count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSMutableArray *annotationType = [_annotations objectAtIndex:section];
  return [annotationType count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"Image Annotations";
  } else {
    return @"Note Annotations";
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"CellIdentifier";
  EECustomTableViewCell *cell = (EECustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) {
    cell = [[EECustomTableViewCell alloc] init];
  }
  NSArray *annotationType = [_annotations objectAtIndex:[indexPath section]];
  if ([annotationType count] > indexPath.row) {
    EEAnnotation *currentAnnotation = annotationType[indexPath.row];
    [cell setAnnotationForCell:currentAnnotation];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *annotationType = [_annotations objectAtIndex:indexPath.section];
  EEAnnotation *currentAnnotation = annotationType[indexPath.row];
  UINavigationController *modalNavController;
  if (currentAnnotation.image) {
    EEDetailImageViewController *divc = [[EEDetailImageViewController alloc] initWithAnnotation:currentAnnotation map:nil];
    modalNavController = [[UINavigationController alloc] initWithRootViewController:divc];
  } else {
    EENoteViewController *nvc = [[EENoteViewController alloc] initWithAnnotation:currentAnnotation map:nil];
    modalNavController = [[UINavigationController alloc] initWithRootViewController:nvc];
  }
  modalNavController.delegate = self;
  [self presentViewController:modalNavController animated:YES completion:NULL];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 71.0;
}


@end
