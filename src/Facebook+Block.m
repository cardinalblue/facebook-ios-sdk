//
//  Facebook+Block.m
//  PicCollage
//
//  Created by WANG JIM on 2011/9/26.
//  Copyright 2011年 NTUT. All rights reserved.
//

#import "Facebook+Block.h"


static NSString* kGraphBaseURL = @"https://graph.facebook.com/";
static NSString* kRestserverBaseURL = @"https://api.facebook.com/method/";

static NSString* kSDK = @"ios";
static NSString* kSDKVersion = @"2";


@implementation Facebook (Block)


- (void)requestWithGraphPath:(NSString *) _graphPath
                      params:(NSMutableDictionary*) _params
                      method:(NSString*) _method
              completedBlock:(FBRequestCompletedBlock) _completedBlock
{
    NSString *fullURL = [kGraphBaseURL stringByAppendingString:_graphPath];
    [self openUrl:fullURL params:_params httpMethod:_method completedBlock:_completedBlock];
}

- (void)requestWithMethodName:(NSString *)_methodName 
                    andParams:(NSMutableDictionary *)_params 
                andHttpMethod:(NSString *)_method 
               completedBlock:(FBRequestCompletedBlock)_completedBlock
{
    NSString * fullURL = [kRestserverBaseURL stringByAppendingString:_methodName];
    [self openUrl:fullURL params:_params httpMethod:_method completedBlock:_completedBlock];
}

- (FBRequest *)openUrl:(NSString *)url
               params:(NSMutableDictionary *)params
           httpMethod:(NSString *)httpMethod
       completedBlock:(FBRequestCompletedBlock)_completedBlock 
{
    [params setValue:@"json" forKey:@"format"];
    [params setValue:kSDK forKey:@"sdk"];
    [params setValue:kSDKVersion forKey:@"sdk_version"];
    if ([self isSessionValid]) {
        [params setValue:self.accessToken forKey:@"access_token"];
    }
    
    [_request release];
    //modify request to have block
    _request = [[FBBlockRequest getRequestWithParams:params
                                     httpMethod:httpMethod
                                     requestURL:url
                                 completedBlock:_completedBlock] retain];
    [_request connect];
    return _request;
}
@end

@interface FBRequest ()

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error;
- (void)handleResponseData:(NSData *)data;

@end

@implementation FBBlockRequest

@synthesize completedBlock = _completedBlock;

- (void)dealloc {
    [_completedBlock release]; _completedBlock = nil;
    [super dealloc];
}

+ (FBBlockRequest *)getRequestWithParams:(NSMutableDictionary *)params
                              httpMethod:(NSString *)httpMethod
                              requestURL:(NSString *)url
                          completedBlock:(FBRequestCompletedBlock) _completedBlock
{
    FBBlockRequest * request = [[[FBBlockRequest alloc] init] autorelease];
    request.delegate = nil;
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.connection = nil;
    request.responseText = nil;
    request.completedBlock = _completedBlock;
    
    return request;
}


- (void)handleResponseData:(NSData *)data {
    [super handleResponseData:data];
    
    if (_completedBlock) {
        NSError* error = nil;
        id result = [self parseJsonResponse:data error:&error];
        _completedBlock(self, result, error);
        [_completedBlock release]; _completedBlock = nil;
    }
}

- (void)failWithError:(NSError *)error
{
    if (_completedBlock) {
        _completedBlock(self, nil, error);
        [_completedBlock release]; _completedBlock = nil;
    }
}


@end
