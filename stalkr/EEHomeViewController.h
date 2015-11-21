// Copyright 2004-present Facebook. All Rights Reserved.

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface EEHomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>
{
  UICollectionView *_collectionView;
  UICollectionViewFlowLayout *_flowLayout;
}

@end
