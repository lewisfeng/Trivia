//
//  ViewController.m
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-28.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "ViewController.h"
#import "Game.h"
#import "HostViewController.h"
#import "ClientViewController.h"
#import "UIImage+animatedGIF.h"

#define kAnimateDru 1.5f

@interface ViewController () <UITextFieldDelegate, GameDelegate>

@property (nonatomic, strong) Game *game;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *validNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *hostOrJoinBtn;
@property (weak, nonatomic) IBOutlet UIImageView *gifImgView;

- (IBAction)hostOrJoinBtnClicked:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self startAnimatingGif];
    
    [self loadGame];
}

- (void)loadGame {

    self.game = [[Game alloc] init];
    self.game.delegate = self;
    [self.game loadGame];
}

#pragma mark - <GameDelegate>
- (void)isModelDataNil:(BOOL)isModelDataNil {

    if (isModelDataNil) { // No data, maybe internet problem
        
        NSString *msgStr = @"Countn't get data, please check your internet connection";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msgStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - <GameDelegate>
- (void)isThereAHost:(BOOL)isThereAHost {

    self.game.isThereAHost = isThereAHost;
    
    NSString *imgName;
    
    if (isThereAHost) { // Found host
        
        imgName = @"join-game-bg.png";
        
    } else {            // No host
        
        imgName = @"host-game-bg.png";
    }
    
    [self.hostOrJoinBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    [self removeGifImgView];
}


- (void)startAnimatingGif {
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"Preloader_6" ofType:@"gif"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    self.gifImgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)isPlayerEnteredValidName {
    
    BOOL isPlayerEnteredValidName = NO;
    
    if (self.textField.text.length > 3) {
        
        isPlayerEnteredValidName = YES;
    }
    
    return isPlayerEnteredValidName;
}


- (void)removeGifImgView {
    
    [UIView animateWithDuration:kAnimateDru animations:^{
        
        self.gifImgView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:kAnimateDru animations:^{
            
            [self.gifImgView removeFromSuperview];
            
            self.hostOrJoinBtn.alpha = 1.0f;
        }];
    }];
}

- (IBAction)hostOrJoinBtnClicked:(UIButton *)sender {
    
    sender.enabled = NO;
    
//    if ([self isPlayerEnteredValidName]) {
    
        [self.game.handler stopAdvertisingPeer];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (self.game.isThereAHost) { // Host already exist - Can only join
            
            ClientViewController *clientVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ClientViewController"];
            clientVC.playerName = self.textField.text;
            [self presentViewController:clientVC animated:YES completion:nil];
            
        } else { // No host - Can only host
            
            HostViewController *hostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
            hostVC.playerName = self.textField.text;
            [self presentViewController:hostVC animated:YES completion:nil];
        }
    
//    } else {
//        
//        [self playerDoesntEnterValidName];
//    }
}

- (void)playerDoesntEnterValidName {
    
    [self setUpValidNameLabel];
    
    [UIView animateWithDuration:1.9f animations:^{
        
        self.validNameLabel.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        self.hostOrJoinBtn.enabled = YES;
    }];
}

- (void)setUpValidNameLabel {
    
    self.validNameLabel.layer.cornerRadius = 9.0f;
    self.validNameLabel.clipsToBounds=YES;
}
@end
