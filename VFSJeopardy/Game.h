//
//  Game.h
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-30.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Player.h"
#import "MPCHandler.h"

@protocol GameDelegate <NSObject>

- (void)isModelDataNil:(BOOL)isModelDataNil;
- (void)isThereAHost  :(BOOL)isThereAHost;  

@end

@interface Game : NSObject

extern NSString *const kSeparator;
extern NSTimeInterval const kCountDownDur;

@property (nonatomic, weak)   id<GameDelegate> delegate;

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) MPCHandler *handler;

@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL isOver;
@property (nonatomic, assign) BOOL isThereAHost;

@property (nonatomic, retain) NSMutableArray *questions;

- (void)loadGame;

- (id)initWithPlayerName:(NSString *)name andIsHost:(BOOL)isHost;

@end
