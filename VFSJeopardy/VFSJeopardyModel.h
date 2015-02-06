//
//  VFSJeopardyModel.h
//  VFSJeopardy
//
//  Created by Pedro Landaverde on 2014-12-14.
//  Copyright (c) 2014 Pedro Landaverde. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VFSJeopardyModel : NSObject

+ (void)pullDataFromJSONWithWithCompletion:(void (^)(NSMutableArray *questions))completion;

+ (BOOL)isModelDataNil;

@end
