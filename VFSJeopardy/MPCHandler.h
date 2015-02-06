//
//  MPCHandler.h
//  VFSJeopardy
//
//  Created by Pedro Landaverde on 2014-12-06.
//  Copyright (c) 2014 Pedro Landaverde. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPCHandler : NSObject

extern NSString *const kConnectedPeers;
extern NSString *const kServiceType;
extern NSString *const kStartGame;
extern NSString *const kVFSJeopardy_DidChangeStateNotification;
extern NSString *const kVFSJeopardy_DidReceiveDataNotification;
extern NSString *const kReceivedMsgStr;
extern NSString *const kPeerName;
extern NSString *const kPeerState;
extern NSString *const kGenerateRandomQuestion;
extern NSString *const kUpdatePlayerScoreOnTopView;
extern NSString *const kDisableOptionBtns;
extern NSString *const kDidReceiveInvitation;
extern NSString *const kGameover;



- (id)initWithPlayerPeerID:(NSString *)peerID and:(BOOL)isHost;
- (void)sendDataToOnePlayer:(NSArray *)onePlayer WithDataStr:(NSString *)string; // send client bg tag

- (void)sendDataWith:(NSString *)string;

- (void)stopAdvertisingPeer;

- (void)stopBrowingForPeers;

- (void)lookingForHost;

@end

