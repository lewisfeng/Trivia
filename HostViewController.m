//
//  ViewController.m
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-28.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "HostViewController.h"
#import "Question.h"
#import "AppleTVView.h"
#import "Game.h"
#import "UIImage+animatedGIF.h"

#define kDur 0.5f

@interface HostViewController () <UITableViewDataSource, UITableViewDelegate>

// IBOutlet
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *plusOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionReminingLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel01;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel02;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel03;
@property (weak, nonatomic) IBOutlet UILabel *continueLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UIButton *option01Btn;
@property (weak, nonatomic) IBOutlet UIButton *option02Btn;
@property (weak, nonatomic) IBOutlet UIButton *option03Btn;

@property (weak, nonatomic) IBOutlet UIButton *continueBtn;

- (IBAction)optionBtnClicked:(UIButton *)sender;
- (IBAction)continueBtnClicked:(UIButton *)sender;

// ----------------------------------------------------------



@property (nonatomic, strong) Game *game;
@property (nonatomic, strong) AppleTVView *appleTV;

@property (nonatomic, strong) UIWindow *secondWindow;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *secondScreenView;

@property (nonatomic, assign) int randomQuestionTag;
@property (nonatomic, assign) int totalQuestionsCount;

@property (nonatomic, strong) UIButton *hostOrJoinBtn;

@property (nonatomic, copy) NSString *rightAnswerTagStr;


@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, strong) NSDate *timerExpDate;

@property (nonatomic, retain) NSMutableArray *connectedPeers;
@property (nonatomic, retain) NSMutableArray *answeredRightPlayers;
@property (nonatomic, retain) NSMutableArray *optionBtns;
@property (nonatomic, retain) NSMutableArray *optionLabels;

@property (nonatomic, retain) NSMutableArray *allPlayers;

@end

@implementation HostViewController {

    BOOL _isFirstTimeLoadQaA;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadGame];
    
    [self initAllIBOutletLabels];
}

- (void)initAllIBOutletLabels {
    
    self.game.player.name     = self.playerName;
    self.playerNameLabel.text = self.game.player.name;
    
    self.questionReminingLabel.text = [NSString stringWithFormat:@"%i of %i", self.totalQuestionsCount - self.game.questions.count, self.totalQuestionsCount];
    self.optionBtns   = [NSMutableArray arrayWithObjects:self.option01Btn, self.option02Btn, self.option03Btn, nil];
    self.optionLabels = [NSMutableArray arrayWithObjects:self.optionLabel01, self.optionLabel02, self.optionLabel03, nil];
    
    self.continueBtn.enabled = NO;
    self.continueBtn.alpha = 0.5f;
    
    self.allPlayers = [NSMutableArray array];
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
}

- (void)changeBgImg {
    
    self.bgImgView.image = [UIImage imageNamed:@"gameplay-mobile-light-blue.png"];
}

- (void)sendClientBgImgTag {
    
    for (MCPeerID *peer in self.connectedPeers) {
        
        NSString *name = [[peer.displayName componentsSeparatedByString: kSeparator] objectAtIndex:0];
        
        NSArray *onePlayer = [NSArray arrayWithObject:peer];

        for (UILabel *nameLabel in self.appleTV.nameLabels) {
            
            if ([nameLabel.text isEqualToString:name]) {
                
                NSString *tagStr = [NSString stringWithFormat:@"%i", nameLabel.tag];
                
                [self.game.handler sendDataToOnePlayer:onePlayer WithDataStr:tagStr];
                
                break;
            }
        }
    }
}

- (IBAction)continueBtnClicked:(UIButton *)sender {
    
    sender.alpha = 0.5f;
    sender.enabled = NO;
    
    if (!self.game.isStarted) { // Game not start yet
        
        [self changeBgImg];
        
        self.game.isStarted = YES;
        
        self.continueLabel.text = @"CONTINUE";
        self.playerScoreLabel.text = @"0";
        
        [self.appleTV.gifImgView removeFromSuperview]; // Remove gif from apple tv

        [self.tableView removeFromSuperview];
        self.tableView = nil;
        
        [self.game.handler sendDataWith:self.game.player.peerID]; // Send host name to all peers - THIS HAS TO BE THE FIRST SEND TO CLIENT
        [self sendClientBgImgTag];                                // Send this to client so client can select bg depends on ...
        [self.game.handler sendDataWith:kStartGame];              // Send start game to all peers
        [self.game.handler stopBrowingForPeers];                  // Stop inviting
        
        [self generateRandomQuestion];
        
    } else { // Game started - Continue Button
        
        [self generateRandomQuestion];
        
        [self enableOptionButtons];
    }
}

- (void)loadGame {
    
    self.playerName = [[UIDevice currentDevice] name];
    
    self.game = [[Game alloc] initWithPlayerName:self.playerName andIsHost:YES];
    
    [self addNotification];
    [self initSecondScreen];
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.totalQuestionsCount = self.game.questions.count;
}


- (void)initSecondScreen {
    
    if ([[UIScreen screens] count] > 1) {
        
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        CGRect screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        self.secondWindow.hidden = NO;
        
        self.appleTV = [[AppleTVView alloc] init];
        [self.secondWindow addSubview:self.appleTV];
        
        self.appleTV.nameLabel01.text  = self.game.player.name; // 01 is the host
        self.appleTV.scoreLabel01.text = @"0";
        
        NSString *path=[[NSBundle mainBundle]pathForResource:@"loading" ofType:@"gif"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        self.appleTV.gifImgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        
        self.totalQuestionsCount = self.game.questions.count;
        
        
        
        
        [self updateSecondScreenBeforeGameStart];
    }
}

- (void)updateSecondScreenBeforeGameStart {
    
    if (!self.game.isStarted) { // Game not start yet
        
        for (UILabel *nameLabel in self.appleTV.nameLabels) {
            nameLabel.text = @"";
        }
        
        for (UILabel *scoreLabel in self.appleTV.scoreLabels) {
            scoreLabel.text = @"";
        }
        
        for (int i = 0; i < self.connectedPeers.count; i ++) {
            
            MCPeerID *peer = self.connectedPeers[self.connectedPeers.count - i - 1];
            
            UILabel *nameLabel = self.appleTV.nameLabels[i];
            
            NSString *playerName = [[peer.displayName componentsSeparatedByString: kSeparator] objectAtIndex:0];
            
            nameLabel.text = playerName;
            
            UILabel *scoreLabel = self.appleTV.scoreLabels[i];
            scoreLabel.text = @"0";
        }
    }
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
    
    if (self.connectedPeers.count > 0) {
        self.continueBtn.enabled = YES;
        self.continueBtn.alpha   = 1.0f;
    }

    if (self.game.isStarted) { // Game started
        
        int state = (int)[[notification userInfo] objectForKey:kPeerState];
        
        if (state == 0) { // Lost Peer
            
            NSString *peerName = [[notification userInfo] objectForKey:kPeerName];
            
            [self lostPeerAfterGameStartedWithPeerName:peerName];
        }
        
    } else { // Game not start
        
        [self.tableView reloadData];
        
        [self updateSecondScreenBeforeGameStart];
    }
    
}

- (void)lostPeerAfterGameStartedWithPeerName:(NSString *)peerName {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (UILabel *nameLabel in self.appleTV.nameLabels) {
            
            if ([nameLabel.text isEqualToString:peerName]) {
                nameLabel.textColor = [UIColor lightGrayColor];
                nameLabel.alpha = 0.3f;
                NSInteger tag = nameLabel.tag;
                UILabel *scoreLabel = self.appleTV.scoreLabels[tag];
                scoreLabel.textColor = [UIColor lightGrayColor];
                scoreLabel.alpha = 0.3f;
                break;
            }
        }
    });
}

- (void)updatePlayerScoreOnSecondScreen {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Host
        UILabel *hostLabel = self.appleTV.scoreLabel01;
        
        if (self.game.player.score > hostLabel.text.intValue) {
            
            hostLabel.text = [NSString stringWithFormat:@"%i", self.game.player.score];
            
            [self zoomAnimatingWith:hostLabel and:self.appleTV];
        }
        
        // Client
        for (NSString *playerName in self.answeredRightPlayers) {
            
            for (UILabel *nameLabel in self.appleTV.nameLabels) {
                
                if ([playerName isEqualToString:nameLabel.text]) {
                    
                    UILabel *scoreLabel = self.appleTV.scoreLabels[nameLabel.tag];
                    
                    int score = scoreLabel.text.intValue;
                    
//                    NSLog(@"player name = %@   score = %i", playerName, score);
                    
                    score += 1;
                    
//                    NSLog(@"2 - player name = %@   score = %i", playerName, score);
                    
                    scoreLabel.text = [NSString stringWithFormat:@"%i", score];
                    
                    [self zoomAnimatingWith:scoreLabel and:self.appleTV];
                    
                    break;
                }
            }
        }
        
        for (UIImageView *imgView in self.appleTV.optionImgViews) {
            
            if (imgView.tag == self.rightAnswerTagStr.intValue) {
                imgView.image = [UIImage imageNamed:@"CheckMark01.png"];
            } else {
                imgView.image = [UIImage imageNamed:@"CrossMark01.png"];
            }
            imgView.hidden = NO;
        }
    });
}

- (void)receivedDataWithNotification:(NSNotification *)notification {
    
    NSString *receivedMsg = [[notification userInfo] objectForKey:kReceivedMsgStr];
    NSString *peerName    = [[notification userInfo] objectForKey:kPeerName];
    
//    NSLog(@"RightAnswerTag = %@ received - %@", self.rightAnswerTagStr, receivedMsg);
    

    if (![receivedMsg isEqualToString:kGenerateRandomQuestion] && ![receivedMsg isEqualToString:kUpdatePlayerScoreOnTopView]) {
        
        if ([receivedMsg isEqualToString:self.rightAnswerTagStr]) {
            
            NSString *name = [[peerName componentsSeparatedByString: kSeparator] objectAtIndex:0];
            
            if (![self.answeredRightPlayers containsObject:name]) {
                [self.answeredRightPlayers addObject:name];
            }
        }
    }
}


- (void)upDatePlayerSCoreOnTopView {
    
    NSLog(@"Host upDatePlayerSCoreOnTopView - player score - %i    text value - %i", self.game.player.score, self.playerScoreLabel.text.intValue);
    
    if (self.game.player.score > self.playerScoreLabel.text.intValue) {
        
        self.playerScoreLabel.text = [NSString stringWithFormat:@"%i", self.game.player.score];
        
        // User Device
        self.plusOneLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        
        [UIView animateWithDuration:1.0f animations:^{
            
            self.plusOneLabel.alpha = 1.0f;
            self.plusOneLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 3.3f, 3.3f);
            
        } completion:^(BOOL finished) {
            
            self.plusOneLabel.alpha = 0.0f;
        }];
    }
}

- (void)zoomAnimatingWith:(UILabel *)label and:(UIView *)view {
    
    // Apple TV
    UILabel *plusOneLabel = [[UILabel alloc] initWithFrame:label.frame];
    CGRect frame = plusOneLabel.frame;
    frame.origin.y -= frame.size.height;
    plusOneLabel.frame = frame;
    plusOneLabel.text = @"+1";
    plusOneLabel.textColor = [UIColor redColor];
    plusOneLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:plusOneLabel];
    
    plusOneLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    
    [UIView animateWithDuration:1.0f
                     animations:^{
                         
                         plusOneLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 3.3f, 3.3f);
                     } completion:^(BOOL finished) {
                         [plusOneLabel removeFromSuperview];
                     }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.connectedPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    MCPeerID *peer = self.connectedPeers[indexPath.row];
    
    NSString *name = [[peer.displayName componentsSeparatedByString: kSeparator] objectAtIndex:0];
    
    cell.textLabel.text = name;

    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}


- (void)setUpPlayerNameAndScoreLabelWith:(UILabel *)label {
    
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor purpleColor];
    label.font = [UIFont fontWithName:@"GillSans-Light" size:15];
    [self.secondScreenView addSubview:label];
}


- (void)addNewOptionsWith:(Question *)question {

    [self getOptionTextWith:question andOptionLabelsArray:self.optionLabels];
}

- (void)hostSendRandomQuestionTagToClientsWith:(int)randomQuestionTag {
    
    NSString *tagStr = [NSString stringWithFormat:@"%i", self.randomQuestionTag];
    [self.game.handler sendDataWith:tagStr];
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

- (void)updateQuestionAndOptionsOnSecondScreenWithQuestion:(Question *)question {
    
    self.appleTV.questionReminingLabel.text = [NSString stringWithFormat:@"%i of %i", self.totalQuestionsCount - self.game.questions.count, self.totalQuestionsCount];
    
    if (_isFirstTimeLoadQaA) {
        
        _isFirstTimeLoadQaA = NO;
        
        self.appleTV.questionLabel.text = question.question;
        
        [self getOptionTextWith:question andOptionLabelsArray:self.appleTV.optionLabels];
        
    } else {
        
        [UIView animateWithDuration:kDur animations:^{
            
            CGRect frame = self.appleTV.questionLabel.frame;
            frame.origin.x = self.appleTV.frame.size.width + frame.size.width;
            self.appleTV.questionLabel.frame = frame;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:kDur animations:^{
                
                for (int i = 0; i < question.options.count; i ++) {
                    
                    UILabel *optionLabel = self.appleTV.optionLabels[i];
                    
                    CGRect frame = optionLabel.frame;
                    frame.origin.x = self.appleTV.frame.size.width + frame.size.width;
                    optionLabel.frame = frame;
                }
                
            } completion:^(BOOL finished) {
                
                CGRect frame = self.appleTV.questionLabel.frame;
                frame.origin.x = -frame.size.width;
                self.appleTV.questionLabel.frame = frame;
                
                self.appleTV.questionLabel.text = question.question;
                
                for (int i = 0; i < question.options.count; i ++) {
                    
                    UILabel *optionLabel = self.appleTV.optionLabels[i];
                    
                    CGRect frame = optionLabel.frame;
                    frame.origin.x = -frame.size.width;
                    optionLabel.frame = frame;
                    
                    NSString *str;
                    if (i == 0) {
                        str = @"A. ";
                    } else if (i == 1) {
                        str = @"B. ";
                    } else {
                        str = @"C. ";
                    }
                    
                    optionLabel.text = [NSString stringWithFormat:@"%@%@", str, question.options[i]];
                }
                
                [UIView animateWithDuration:kDur animations:^{
                    
                    CGRect frame = self.appleTV.questionLabel.frame;
                    frame = self.appleTV.questionLabelFrame;
                    self.appleTV.questionLabel.frame = frame;
                    
                } completion:^(BOOL finished) {
                    
                    [self setUpCountingDown];
                    
                    [self hostSendRandomQuestionTagToClientsWith:self.randomQuestionTag];
                    
                    for (int i = 0; i < question.options.count; i ++) {
                        
                        UILabel *optionLabel = self.appleTV.optionLabels[i];
                        
                        [UIView animateWithDuration:kDur animations:^{
                            
                            CGRect frame = optionLabel.frame;
                            frame = [self.appleTV.optionLabelFrames[i] CGRectValue];
                            optionLabel.frame = frame;
                        }];
                    }
                }];
                
            }];
        }];
    }
}

- (void)generateRandomQuestion {
    
    if (self.game.questions.count > 0) {
        
        self.answeredRightPlayers = [NSMutableArray array];
        
        for (UIImageView *imgView in self.appleTV.optionImgViews) {
            imgView.hidden = YES;
        }
        
        self.appleTV.questionReminingImgV.hidden = NO;
        self.appleTV.timerImgV.hidden            = NO;
        self.appleTV.timeLeftLabel.hidden        = NO;
        
        self.randomQuestionTag   = arc4random() % self.game.questions.count;
        Question *question     = self.game.questions[self.randomQuestionTag];
        self.rightAnswerTagStr = question.rightAnswerTagStr;
        
        [self.game.questions removeObject:question];

        self.questionReminingLabel.text = [NSString stringWithFormat:@"%i of %i", self.totalQuestionsCount - self.game.questions.count, self.totalQuestionsCount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateQuestionAndOptionsOnSecondScreenWithQuestion:question];
            [self addNewOptionsWith:question];
        });
        
        if (self.game.questions.count == 0) { // No more questions - Game Over
            
             self.continueLabel.text = @"OVER";
        }
        
    } else { // Game Over
        
        [self gameOver];
        
        [self.game.handler sendDataWith:kGameover];
    }
}



- (void)gameOver {
    
    // Device
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
    
    // AppleTV
    [UIView animateWithDuration:1.5f animations:^{
        
        for (UIView *view in self.appleTV.subviews) {
            
            view.alpha = 0.0f;
        }

    } completion:^(BOOL finished) {
        
        [self.allPlayers addObject:self.game.player]; // Add youself
        
        for (int i = 0; i < self.appleTV.nameLabels.count; i ++) {
            
            UILabel *nameLabel = self.appleTV.nameLabels[i];
            
            if (nameLabel.text.length > 0) {
                
                NSString *name = nameLabel.text;
                
                UILabel *scoreLabel = self.appleTV.scoreLabels[i];
                int score = scoreLabel.text.intValue;
                
                
                Player *player = [[Player alloc] initWithName:name andScore:score];
                [self.allPlayers addObject:player];
            }
        }
        
        NSArray *sorted = [self.allPlayers sortedArrayUsingComparator:^(Player *p1, Player *p3){
            
            if (p1.score > p3.score) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (p1.score < p3.score) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        self.allPlayers = [NSMutableArray arrayWithArray:sorted];
        
        [self.appleTV removeFromSuperview];
        self.appleTV = [[AppleTVView alloc] initWitFinialScreen];
        [self.secondWindow addSubview:self.appleTV];
        
        [UIView animateWithDuration:1.5f animations:^{
            
            self.appleTV.finialBgImgView.alpha = 1.0f;
            UIImageView *imgV = self.appleTV.finalWinnerImgViews[0];
            imgV.alpha  = 1.0f;

            for (int i = 0; i < self.allPlayers.count; i ++) {
                
                Player *player = self.allPlayers[i];
                
                NSLog(@"Loop - %@", player.name);
                
                UILabel *label = self.appleTV.finalWinnerLabels[i];
                
                label.text = [NSString stringWithFormat:@"%i. %@ (%i)", i + 1, player.name, player.score];
                
                label.alpha = 1.0f;
            }
        }];
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
        
        [self enableContinueBtn];
        
        [self.game.handler sendDataWith:kUpdatePlayerScoreOnTopView];
        
        [self.game.handler sendDataWith:kDisableOptionBtns];
        
        [self upDatePlayerSCoreOnTopView];
        [self updatePlayerScoreOnSecondScreen];
        
        [self disabelOptionButtons];
    }
    
    self.appleTV.timeLabel.text = self.timeLeftLabel.text;
}

- (void)disabelOptionButtons {
    
    for (UIButton *btn in self.optionBtns) {
        
        if (btn.userInteractionEnabled) {
            btn.alpha = 0.5f;
            btn.userInteractionEnabled = NO;
        }
    }
}

- (void)enableOptionButtons {
    
    for (UIButton *btn in self.optionBtns) {

        btn.alpha = 1.0f;
        btn.userInteractionEnabled = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    }
}

- (void)enableContinueBtn {
    
    self.continueBtn.enabled = YES;
    self.continueBtn.alpha = 1.0f;
}

@end
