//
//  Player.h
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-28.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface Player : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuID;
@property (nonatomic, copy) NSString *peerID;

@property (nonatomic, strong) MCPeerID *mcPeerID;

@property (nonatomic, assign) int score;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name andScore:(int)score;

@end
