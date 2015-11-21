// Copyright 2004-present Facebook. All Rights Reserved.

#import <UIKit/UIKit.h>

@protocol EEMapsTableViewControllerDelegate;

@interface EEMapsTableViewController : UITableViewController

@property (nonatomic, weak) id <EEMapsTableViewControllerDelegate> delegate;

@end

@protocol EEMapsTableViewControllerDelegate <NSObject>

- (void)mapsTableViewDidRemoveCurrentMap:(EEMapsTableViewController *)mtvc;

@end
