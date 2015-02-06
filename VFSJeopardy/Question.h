//
//  Question.h
//  VFSJeopardy
//
//  Created by Pedro Landaverde on 2014-12-14.
//  Copyright (c) 2014 Pedro Landaverde. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (nonatomic, strong) NSString       *question;
@property (nonatomic, strong) NSString       *rightAnswerTagStr;
@property (nonatomic, strong) NSMutableArray *options;

- (id)initWith:(NSDictionary *)dict;

@end
