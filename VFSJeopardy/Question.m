//
//  Question.m
//  VFSJeopardy
//
//  Created by Pedro Landaverde on 2014-12-14.
//  Copyright (c) 2014 Pedro Landaverde. All rights reserved.
//

#import "Question.h"

@implementation Question

- (id)initWith:(NSDictionary *)dict {
    
    if (self = [super init]) {
        
        self.question          = dict[@"text"];
        self.rightAnswerTagStr = dict[@"answer"];
        self.options           = [NSMutableArray array];
        
        for (NSDictionary *optionsDict in dict[@"options"]) {
            
            [self.options addObject:optionsDict[@"text"]];
        }
    }
    
    return self;
}

@end
