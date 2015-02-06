//
//  AppleTVView.m
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-29.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "AppleTVView.h"

@interface AppleTVView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel02;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel03;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel04;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel05;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel06;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel07;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel08;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel02;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel03;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel04;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel05;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel06;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel07;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel08;

@property (weak, nonatomic) IBOutlet UILabel *optionLabel01;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel02;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel03;

@property (weak, nonatomic) IBOutlet UIImageView *optionImgView01;
@property (weak, nonatomic) IBOutlet UIImageView *optionImgView02;
@property (weak, nonatomic) IBOutlet UIImageView *optionImgView03;

@property (nonatomic, assign) CGRect optionLabelFrame01;
@property (nonatomic, assign) CGRect optionLabelFrame02;
@property (nonatomic, assign) CGRect optionLabelFrame03;

@end

@implementation AppleTVView

- (id)initWitFinialScreen {
    
    if (self = [super init]) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"AppleTV" owner:self options:nil] objectAtIndex:1];
    }
    
    return self;
}

- (id)init {
    
    if (self = [super init]) {

        self = [[[NSBundle mainBundle] loadNibNamed:@"AppleTV" owner:self options:nil] objectAtIndex:0];
        
        self.questionLabelFrame = self.questionLabel.frame;
        
        self.optionLabelFrame01 = self.optionLabel01.frame;
        self.optionLabelFrame02 = self.optionLabel02.frame;
        self.optionLabelFrame03 = self.optionLabel03.frame;
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]] && ![view isEqual:self.questionLabel] && ![view isEqual:self.timeLeftLabel]) {
                
                [(UILabel *)view setText:@""];
            }
        }
        
        self.nameLabels   = [NSMutableArray arrayWithObjects:self.nameLabel02,  self.nameLabel03, self.nameLabel04, self.nameLabel05, self.nameLabel06, self.nameLabel07, self.nameLabel08, nil];
        
        self.scoreLabels  = [NSMutableArray arrayWithObjects:self.scoreLabel02, self.scoreLabel03, self.scoreLabel04, self.scoreLabel05, self.scoreLabel06, self.scoreLabel07,self.scoreLabel08, nil];
        
        self.optionLabels = [NSMutableArray arrayWithObjects:self.optionLabel01, self.optionLabel02, self.optionLabel03, nil];
        
        self.optionImgViews = [NSMutableArray arrayWithObjects:self.optionImgView01, self.optionImgView02, self.optionImgView03, nil];
        
        self.optionLabelFrames = [NSArray arrayWithObjects:[NSValue valueWithCGRect:self.optionLabelFrame01], [NSValue valueWithCGRect:self.optionLabelFrame02], [NSValue valueWithCGRect:self.optionLabelFrame03], nil];
    }
    
    return self;
}

@end
