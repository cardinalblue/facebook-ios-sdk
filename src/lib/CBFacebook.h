//
//  CBFacebook.h
//  PicCollage
//
//  Created by Cham Jaime on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Facebook.h"

@interface CBFacebook : Facebook <
    FBSessionDelegate>

@property (nonatomic, assign) id<FBSessionDelegate> outwardSessionDelegate;

#pragma mark - Class configuration
+ (void)setAppId:(NSString *)appId;
+ (NSString *)appId;

+ (void)setLocalAppId:(NSString *)localAppId;
+ (NSString *)localAppId;

+ (void)setPermissions:(NSArray *)permissions;
+ (NSArray *)permissions;

#pragma mark - Object lifecycle
// New designated initializer
- (id)init;

#pragma mark - Login actions
- (BOOL)isAuthorized;
- (void)authorize;
- (BOOL)ensureAuthorization;


@end
