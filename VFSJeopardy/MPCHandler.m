//
//  MPCHandler.m
//  VFSJeopardy
//
//  Created by Pedro Landaverde on 2014-12-06.
//  Copyright (c) 2014 Pedro Landaverde. All rights reserved.
//

#import "MPCHandler.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MPCHandler () <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>



@property (nonatomic, strong) MCPeerID  *peerID;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

@property (nonatomic, strong) MCNearbyServiceAdvertiser *nearbySA;
@property (nonatomic, strong) MCNearbyServiceBrowser    *nearbySB;

@property (nonatomic, assign) BOOL isThereAHost;

@end

@implementation MPCHandler

NSString *const kConnectedPeers                         = @"CONNECTEDPEERS";
NSString *const kServiceType                            = @"VFSJEOPARDY";
NSString *const kStartGame                              = @"STARTGAME";
NSString *const kVFSJeopardy_DidChangeStateNotification = @"VFSJeopardy_DidChangeStateNotification";
NSString *const kVFSJeopardy_DidReceiveDataNotification = @"VFSJeopardy_DidReceiveDataNotification";
NSString *const kReceivedMsgStr                         = @"ReceivedMsgStr";
NSString *const kPeerName                               = @"PeerName";
NSString *const kGenerateRandomQuestion                 = @"GenerateRandomQuestion";
NSString *const kPeerState                              = @"State";
NSString *const kUpdatePlayerScoreOnTopView             = @"UpdatePlayerScoreOnTopView";
NSString *const kDisableOptionBtns                      = @"DisableOptionBtns";
NSString *const kDidReceiveInvitation                   = @"DidReceiveInvitation";
NSString *const kGameover                               = @"GAMEOVER";



- (void)lookingForHost {
    
    MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:@"LOOKINGFORHOST"];
    self.nearbySA = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID discoveryInfo:nil serviceType:kServiceType];
    self.nearbySA.delegate = self;
    [self.nearbySA startAdvertisingPeer];
}


- (void)stopAdvertisingPeer {
    
    [self.nearbySA stopAdvertisingPeer];
    self.nearbySA.delegate = nil;
    self.nearbySA = nil;
}

- (id)initWithPlayerPeerID:(NSString *)peerID and:(BOOL)isHost {
    
    if (self = [super init]) {

        MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:peerID];
        self.mySession = [[MCSession alloc] initWithPeer:myPeerID];
        self.mySession.delegate = self;
        
        self.nearbySA = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID discoveryInfo:nil serviceType:kServiceType];
        self.nearbySA.delegate = self;
        
        self.nearbySB = [[MCNearbyServiceBrowser alloc] initWithPeer:myPeerID serviceType:kServiceType];
        self.nearbySB.delegate = self;
        
        if (isHost) {

            [self.nearbySB startBrowsingForPeers];
        } else {
            [self.nearbySA startAdvertisingPeer];
        }
    }
    return self;
}

- (void)stopBrowingForPeers {
    [self.nearbySB stopBrowsingForPeers];
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    if (state != MCSessionStateConnecting) {
        
//        NSLog(@"PeerID = %@ State = %i", peerID.displayName, state);
        
        NSDictionary *userInfo = @{kPeerName : peerID.displayName, kPeerState : @(state), kConnectedPeers : self.mySession.connectedPeers};
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kVFSJeopardy_DidChangeStateNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    }
}


- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {

    NSString *receivedMsgStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"Received msg from %@ - %@", peerID.displayName, receivedMsgStr);
    
    NSDictionary *userInfo = @{kReceivedMsgStr: receivedMsgStr, kPeerName: peerID.displayName};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kVFSJeopardy_DidReceiveDataNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

- (void)sendDataToOnePlayer:(NSArray *)onePlayer WithDataStr:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.mySession sendData:data toPeers:onePlayer withMode:MCSessionSendDataReliable error:nil];
}

- (void)sendDataWith:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.mySession sendData:data toPeers:self.mySession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
}



#pragma mark -  Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {

    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiveInvitation
                                                        object:nil
                                                      userInfo:nil];
    
    
    invitationHandler(YES, self.mySession);
}

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    [self.nearbySB invitePeer:peerID toSession:self.mySession withContext:nil timeout:60.0f];
}



- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    //NSLog(@"didNotStartBrowsingForPeers");
}


- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}


@end
