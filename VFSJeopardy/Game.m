//
//  Game.m
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-30.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Game.h"
#import "Question.h"
#import "VFSJeopardyModel.h"

#define kTimeOutDur 3.0f

@implementation Game {
    
    NSTimer *_timer;
}

NSString *const kSeparator = @"*$#";

NSTimeInterval const kCountDownDur = 1.0f;

- (void)loadGame {
    
    // 1. Check data model if is nil
    if (![VFSJeopardyModel isModelDataNil]) { // Data not nil
        
        // 2. if data not nil then check is there a host already
        [self checkIsThereAHost];
        
    } else {
        
        [self.delegate isModelDataNil:YES];
    }
}

- (void)checkIsThereAHost {
    
    self.handler = [[MPCHandler alloc] init];
    [self.handler lookingForHost];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foundHost)
                                                 name:kDidReceiveInvitation
                                               object:nil];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimeOutDur target:self selector:@selector(hostNotFound) userInfo:nil repeats:NO];
    
}

- (void)hostNotFound {
        
    [self.delegate isThereAHost:NO];
    
    [self removeLookingForHostNotification];	
}

- (void)foundHost {

    [_timer invalidate];
    
    [self.delegate isThereAHost:YES];
    
    [self removeLookingForHostNotification];
}

- (void)removeLookingForHostNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidReceiveInvitation object:nil];
}

- (id)initWithPlayerName:(NSString *)name andIsHost:(BOOL)isHost {
    
    if (self = [super init]) {
        
        [VFSJeopardyModel pullDataFromJSONWithWithCompletion:^(NSMutableArray *questions) {
            
            self.questions = questions;
        }];
        
        self.player = [[Player alloc] initWithName:name];
        
        NSString *uuID   = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        self.player.peerID = [NSString stringWithFormat:@"%@%@%@", name, kSeparator, uuID];
        
        self.handler = [[MPCHandler alloc] initWithPlayerPeerID:self.player.peerID and:isHost];
    }
    
    return self;
}

@end
