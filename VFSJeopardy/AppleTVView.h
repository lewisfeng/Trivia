//
//  AppleTVView.h
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-29.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppleTVView : UIView

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel01;

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel01;

@property (weak, nonatomic) IBOutlet UIImageView *gifImgView;

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (nonatomic, assign) CGRect questionLabelFrame;

@property (weak, nonatomic) IBOutlet UIImageView *questionReminingImgV;
@property (weak, nonatomic) IBOutlet UIImageView *timerImgV;
@property (weak, nonatomic) IBOutlet UILabel *questionReminingLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;

@property (nonatomic, strong) NSMutableArray *nameLabels;
@property (nonatomic, strong) NSMutableArray *scoreLabels;
@property (nonatomic, strong) NSMutableArray *optionLabels;
@property (nonatomic, strong) NSMutableArray *optionImgViews;
@property (nonatomic, copy)   NSArray *optionLabelFrames;


@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *finalWinnerLabels;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *finalWinnerImgViews;

@property (weak, nonatomic) IBOutlet UIImageView *finialBgImgView;
- (id)initWitFinialScreen;

@end
