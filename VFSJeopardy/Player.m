//
//  Player.m
//  VFSJeopardy
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-28.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)initWithName:(NSString *)name {
    
    if (self = [super init]) {
        
        self.name = name;
        self.score = 0;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name andScore:(int)score {
    
    if (self = [super init]) {
        
        self.name = name;
        self.score = score;
    }
    
    return self;
}

@end
