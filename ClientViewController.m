//
//  ClientViewController.m
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-02.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "ClientViewController.h"
#import "UIImage+animatedGIF.h"
#import "Question.h"
#import "Game.h"

@interface ClientViewController ()

@property (nonatomic, strong) Game *game;

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *plusOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionReminingLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel01;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel02;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel03;

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UIButton *option01Btn;
@property (weak, nonatomic) IBOutlet UIButton *option02Btn;
@property (weak, nonatomic) IBOutlet UIButton *option03Btn;

@property (weak, nonatomic) IBOutlet UIView *gifVIew;
@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;

- (IBAction)optionBtnClicked:(UIButton *)sender;


@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) NSString *rightAnswerTagStr;

@property (nonatomic, assign) int randomQuestionTag;
@property (nonatomic, assign) int totalQuestionsCount;
@property (nonatomic, assign) int bgImgTag;

@property (nonatomic, retain) NSMutableArray *connectedPeers;

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, strong) NSDate *timerExpDate;

@property (nonatomic, retain) NSMutableArray *answeredRightPlayers;
@property (nonatomic, retain) NSMutableArray *optionBtns;
@property (nonatomic, retain) NSMutableArray *optionLabels;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;



@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadGame];
    
    [self initAllIBOutletLabels];
}

- (void)initAllIBOutletLabels {
    
    self.playerNameLabel.text = self.game.player.name;
    self.questionReminingLabel.text = [NSString stringWithFormat:@"%i of %i", self.totalQuestionsCount - self.game.questions.count, self.totalQuestionsCount];
    self.optionBtns   = [NSMutableArray arrayWithObjects:self.option01Btn, self.option02Btn, self.option03Btn, nil];
    self.optionLabels = [NSMutableArray arrayWithObjects:self.optionLabel01, self.optionLabel02, self.optionLabel03, nil];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"loading" ofType:@"gif"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    self.gifImageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    
    self.bgImgTag = 999;
}

- (void)loadGame {

    self.playerName = [[UIDevice currentDevice] name];
    
    self.game = [[Game alloc] initWithPlayerName:self.playerName andIsHost:NO];
    
    [self addNotification];

    self.totalQuestionsCount = self.game.questions.count;
}

- (IBAction)optionBtnClicked:(UIButton *)sender {
    
    [sender setBackgroundImage:[UIImage imageNamed:@"button-selected.png"] forState:UIControlStateNormal];
    
    for (UIButton *btn in self.optionBtns) {
        
        btn.userInteractionEnabled = NO;
        
        if (![btn isEqual:sender]) {
            
            btn.alpha = 0.5f;
            [btn setBackgroundImage:[UIImage imageNamed:@"button-inactive.png"] forState:UIControlStateNormal];
        }
    }
    
    if (sender.tag == self.rightAnswerTagStr.intValue) {
        self.game.player.score += 1;
    }
        
    NSString *tagStr = [NSString stringWithFormat:@"%i", sender.tag];
    [self.game.handler sendDataWith:tagStr];
    
}

- (void)addNotification {
    
    // 1. PeerChangedStateWithNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerChangedStateWithNotification:)
                                                 name:kVFSJeopardy_DidChangeStateNotification
                                               object:nil];
    // 2. ReceivedDataWithNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDataWithNotification:)
                                                 name:kVFSJeopardy_DidReceiveDataNotification
                                               object:nil];
}

- (void)peerChangedStateWithNotification:(NSNotification *)notification {
    
    self.connectedPeers = [NSMutableArray arrayWithArray:[[notification userInfo] objectForKey:kConnectedPeers]];
}

- (void)changeBgImg {
    
    NSString *bgImgName;
    
    if (self.bgImgTag == 0) {
        bgImgName = @"gameplay-mobile-yellow.png";
    } else if (self.bgImgTag == 1) {
        bgImgName = @"gameplay-mobile-orange.png";
    } else if (self.bgImgTag == 2) {
        bgImgName = @"gameplay-mobile-pink.png";
    } else if (self.bgImgTag == 3) {
        bgImgName = @"gameplay-mobile-dark-blue.png";
    } else if (self.bgImgTag == 4) {
        bgImgName = @"gameplay-mobile-green.png";
    } else if (self.bgImgTag == 5) {
        bgImgName = @"gameplay-mobile-red.png";
    } else if (self.bgImgTag == 6) {
        bgImgName = @"gameplay-mobile-purple.png";
    }

    self.bgImgView.image = [UIImage imageNamed:bgImgName];
}

- (void)startGame {
    
    [self changeBgImg];
    
    self.game.isStarted = YES;
    self.playerScoreLabel.text = @"0";
    
    [self.gifImageView removeFromSuperview];
    [self.gifVIew removeFromSuperview];
}

- (void)receivedDataWithNotification:(NSNotification *)notification {
    
    NSString *receivedMsg = [[notification userInfo] objectForKey:kReceivedMsgStr];
    NSString *peerName    = [[notification userInfo] objectForKey:kPeerName];
    
    if (!self.hostName && [receivedMsg isEqualToString:peerName]) { // Get host name
        
        self.hostName = receivedMsg;
        
    } else {
        
        if (self.bgImgTag == 999) {
            
            self.bgImgTag = receivedMsg.intValue;
            
        } else {
        
            if ([peerName isEqualToString:self.hostName]) { // Only receive msg from host
                
                if ([receivedMsg isEqualToString:kStartGame]) { // Game not start yet
                    
                    [self startGame];
                    
                } else if (self.game.isStarted) { // Game started
                    
                    if ([receivedMsg isEqualToString:kUpdatePlayerScoreOnTopView]) {
                        
                        [self upDatePlayerSCoreOnTopView];
                        
                    } else if ([receivedMsg isEqualToString:kDisableOptionBtns]) {
                        
                        [self disabelOptionButtons];
                        
                    }  else if ([receivedMsg isEqualToString:kGameover]) {
                        
                        [self gameover];
                        
                    } else if (![receivedMsg isEqualToString:kGenerateRandomQuestion] && ![receivedMsg isEqualToString:kUpdatePlayerScoreOnTopView]) {
                        
                        self.randomQuestionTag = receivedMsg.intValue;
                        
                        Question *question = self.game.questions[self.randomQuestionTag];
                        
                        self.rightAnswerTagStr = question.rightAnswerTagStr;
                        
                        [self.game.questions removeObject:question];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{

                            [self setUpCountingDown];
                            [self enableOptionButtons];
                            [self addNewOptionsWith:question];
                        });
                    }
                }
            }
        }
    }
}

- (void)gameover {
    
    [UIView animateWithDuration:1.5f animations:^{
        
        for (UIView *view in self.view.subviews) {
            
            view.alpha = 0.0f;
        }
        
    } completion:^(BOOL finished) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.frame];
        imgView.alpha = 0.0f;
        imgView.image = [UIImage imageNamed:@"finis-screen.png"];
        [self.view addSubview:imgView];
       
        [UIView animateWithDuration:1.5f animations:^{
           
            imgView.alpha = 1.0f;
        }];
    }];
}

- (void)enableOptionButtons {

    for (UIButton *btn in self.optionBtns) {
        
        btn.alpha = 1.0f;
        btn.userInteractionEnabled = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    }
}

- (void)upDatePlayerSCoreOnTopView {

    if (self.game.player.score > self.playerScoreLabel.text.intValue) {
        self.playerScoreLabel.text = [NSString stringWithFormat:@"%i", self.game.player.score];
        [self zoomAnimating];
    }
}

- (void)disabelOptionButtons {

    for (UIButton *btn in self.optionBtns) {
        
        if (btn.userInteractionEnabled) {
            btn.alpha = 0.5f;
            btn.userInteractionEnabled = NO;
        }
    }
}

- (void)zoomAnimating {
    
    // User Device
    self.plusOneLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.plusOneLabel.alpha = 1.0f;
        self.plusOneLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 3.3f, 3.3f);
        
    } completion:^(BOOL finished) {
        
        self.plusOneLabel.alpha = 0.0f;
    }];

}


- (void)setUpCountingDown {
    
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void)countDown {
    
    if (!self.timerExpDate) {
        self.timerExpDate = [NSDate dateWithTimeIntervalSinceNow:kCountDownDur];
    }
    
    NSTimeInterval secondsRemaining = [self.timerExpDate timeIntervalSinceDate:[NSDate date]];
    
    self.timeLeftLabel.text    = [NSString stringWithFormat:@"%.0f", secondsRemaining];
    
    if (secondsRemaining <= 0) {
        
        self.timeLeftLabel.text    = [NSString stringWithFormat:@"0"];
        
        [self.countDownTimer invalidate];
        self.timerExpDate = nil;
        
        [self.game.handler sendDataWith:kUpdatePlayerScoreOnTopView];
        
        [self.game.handler sendDataWith:kDisableOptionBtns];
        
        [self upDatePlayerSCoreOnTopView];

        [self disabelOptionButtons];
    }
}

- (void)addNewOptionsWith:(Question *)question {
    
    self.questionReminingLabel.text = [NSString stringWithFormat:@"%i of %i", self.totalQuestionsCount - self.game.questions.count, self.totalQuestionsCount];
    
    [self getOptionTextWith:question andOptionLabelsArray:self.optionLabels];
}

- (void)getOptionTextWith:(Question *)question andOptionLabelsArray:(NSMutableArray *)optionArrays {
    
    for (int i = 0; i < question.options.count; i ++) {
        
        UILabel *optionLabel = optionArrays[i];
        
        NSString *abc;
        if (i == 0) {
            abc = @"A. ";
        } else if (i == 1) {
            abc = @"B. ";
        } else {
            abc = @"C. ";
        }
        
        optionLabel.text = [NSString stringWithFormat:@"%@%@", abc, question.options[i]];
    }
}






@end
