//
//  CBFacebook.m
//  PicCollage
//
//  Created by Cham Jaime on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

#import "CBFacebook.h"

@implementation CBFacebook

@synthesize outwardSessionDelegate = _outwardSessionDelegate;

#pragma mark - Class configuration

static NSString *appId = nil;
+ (void)setAppId:(NSString *)appId_
{
    appId = [appId_ copy];
}
+ (NSString *)appId
{
    return appId;
}

static NSString *localAppId = nil;
+ (void)setLocalAppId:(NSString *)localAppId_
{
    localAppId = [localAppId_ copy];
}
+ (NSString *)localAppId
{
    return localAppId;
}

static NSArray *permissions = nil;
+ (void)setPermissions:(NSArray *)permissions_
{
    permissions = [permissions_ retain];
}
+ (NSArray *)permissions
{
    return permissions;
}


#pragma mark - Object lifecycle

- (NSArray *)selfObservableNotifications
{
    static NSArray *array = nil;
    if (!array)
        array = [[NSArray arrayWithObjects:
                 @"applicationDidOpenURL", 
                 @"fbDidLogin", 
                 @"fbDidNotLogin", 
                 @"fbDidLogout",
                 nil] retain];
    return array;
}

- (void)dealloc
{
    LogD_;
    for (NSString *name in [self selfObservableNotifications])
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:name
                                                      object:nil];
    [super dealloc];
}

// New designated initializer
- (id)init
{
    LogD_;
    self = [self initWithAppId:[[self class] appId] andDelegate:self];
    
    // Register for notifications
    for (NSString *name in [self selfObservableNotifications])
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleNotification:) 
                                                     name:name
                                                   object:nil];
    
    // Set from User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setExpirationDate:[defaults objectForKey:@"FBExpirationDateKey"]];
    [self setAccessToken:[defaults objectForKey:@"FBAccessTokenKey"]];
    
    return self;
}

#pragma mark - Incoming FbSessionDelegate

- (void)fbDidLogin 
{
    LogD_;
    
    // Save in User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // Send a notification
    [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"fbDidLogin" 
         object:self 
         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                   [self accessToken], @"FBAccessToken",
                   [self expirationDate], @"FBExpirationDate",
                   nil]];
 
    [_outwardSessionDelegate fbDidLogin];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    LogD_;
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // Send a notification
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:@"fbDidNotLogin" 
        object:self 
        userInfo:[NSDictionary dictionaryWithBool:cancelled forKey:@"cancelled"]];
    
    [_outwardSessionDelegate fbDidNotLogin:cancelled];
}

- (void)fbDidLogout
{
    LogD_;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];

    // Send a notification
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:@"fbDidNotLogout" 
        object:self 
        userInfo:nil];
    
    [_outwardSessionDelegate fbDidLogout];
}

#pragma mark - Notifications

- (void)handleNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    LogD(@"notification:%@ userInfo:%@", notification, userInfo);
    if ([notification.name isEqualToString:@"applicationDidOpenURL"])
        [self handleOpenURL:[userInfo objectForKey:@"url"]];
}

#pragma mark - Login actions

- (void)authorize
{
    LogD_;
    [self authorize:[[self class] permissions] localAppId:[[self class] localAppId]];
}
- (BOOL)isAuthorized
{
    return [self isSessionValid];
}
- (BOOL)ensureAuthorization
{
    LogD_;
    if (![self isAuthorized]) {
        [self authorize];
        return NO;
    }
    return YES;
}



@end
