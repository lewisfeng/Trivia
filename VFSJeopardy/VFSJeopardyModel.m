//
//  VFSJeopardyModel.m
//  VFSJeopardy
//
//  Created by Pedro Landaverde on 2014-12-14.
//  Copyright (c) 2014 Pedro Landaverde. All rights reserved.
//

#import "VFSJeopardyModel.h"
#import "Question.h"

@implementation VFSJeopardyModel

+ (BOOL)isModelDataNil {
    
    BOOL isModelDataNil = YES;
    
    if ([self getModelData]) {
        
        isModelDataNil = NO;
    }
    
    return isModelDataNil;
}

+ (NSData *)getModelData {
    
    // Make URL request with server
    NSHTTPURLResponse *response = nil;
    NSURL *url = [NSURL URLWithString:@"http://www.proyectoswombat.com/anexos/vfsjeopardy/server/main.php"];
    
    // Get request and response though URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return data;
}

+ (void)pullDataFromJSONWithWithCompletion:(void (^)(NSMutableArray *))completion {

    NSError *error;
    
    if ([self getModelData]) { // Data not nil
        
        // JSON parsing
        NSMutableArray *result = [NSJSONSerialization JSONObjectWithData:[self getModelData] options:NSJSONReadingMutableContainers error:&error];
        
        NSMutableArray *questions = [NSMutableArray array];
        
        for (NSDictionary *dict in result) {
            
            if (dict) {
                
                Question *question = [[Question alloc] initWith:dict];
                
                [questions addObject:question];
            }
        }
        completion(questions);
    }
}

@end
