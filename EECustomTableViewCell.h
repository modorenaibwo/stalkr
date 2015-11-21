//
//  EECustomTableViewCell.h
//  MapJourney
//
//  Created by Ellen Pei Pei Wu on 8/11/14.
//  Copyright 2004-present Facebook. All Rights Reserved.
//

#import <UIKit/UIKit.h>

@protocol EECustomTableViewCellDelegate;

@interface EECustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *annotationsLabel;
@property (nonatomic, strong) UILabel *dateCreated;
@property (nonatomic, strong) UIButton *annotationsButton;
@property (nonatomic, strong) EEMap *currentMap;
@property (nonatomic, strong) EEAnnotation *currentAnnotation;
@property (nonatomic, weak) id <EECustomTableViewCellDelegate> delegate;

- (void)setMapForCell:(EEMap *)map;
- (void)setAnnotationForCell:(EEAnnotation *)annotation;
- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end

@protocol EECustomTableViewCellDelegate <NSObject>

- (void)customTableViewCellDidTapButton:(EECustomTableViewCell *)cell;

@end
