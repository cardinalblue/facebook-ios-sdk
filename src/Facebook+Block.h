//
//  Facebook+Block.h
//  PicCollage
//
//  Created by WANG JIM on 2011/9/26.
//  Copyright 2011年 NTUT. All rights reserved.
//

#import "Facebook.h"

typedef void (^FBRequestCompletedBlock)(FBRequest *request, id result, NSError *error);

@interface FBBlockRequest : FBRequest 
{
@private 
    FBRequestCompletedBlock _completedBlock;
}

@property (copy) FBRequestCompletedBlock completedBlock;


+ (FBBlockRequest *)getRequestWithParams:(NSMutableDictionary *)params
                              httpMethod:(NSString *)httpMethod
                              requestURL:(NSString *)url
                          completedBlock:(FBRequestCompletedBlock) _completedBlock;
@end

@interface Facebook (Block)

- (FBRequest *)openUrl:(NSString *)url
               params:(NSMutableDictionary *)params
           httpMethod:(NSString *)httpMethod
       completedBlock:(FBRequestCompletedBlock)_completedBlock;

- (void)requestWithGraphPath:(NSString *) _graphPath
                      params:(NSMutableDictionary*) _params
                      method:(NSString*) _method
                       completedBlock:(FBRequestCompletedBlock) _completedBlock;

- (void)requestWithMethodName:(NSString *) _methodName
                     andParams:(NSMutableDictionary *) _params
                 andHttpMethod:(NSString *) _method
                      completedBlock:(FBRequestCompletedBlock) _completedBlock;

@end

