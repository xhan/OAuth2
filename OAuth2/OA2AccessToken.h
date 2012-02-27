//
//  OAuth2AccessToken.h
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface OA2AccessToken : NSObject<NSCoding>

@property(copy,nonatomic) NSString*accessToken;
@property(copy,nonatomic) NSString*refreshToken;
@property(retain,nonatomic) NSDate *expiresAt;
@property(retain,nonatomic) NSSet*scope;
@property(copy,nonatomic) NSString*otherInfo;
@property(readonly,nonatomic) BOOL isExpired;

- (id)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiresDuration:(int)duration scope:(NSSet *)scope;

//+ (OA2AccessToken*)tokenFromSinaResponse:(NSData*)data;
//+ (OA2AccessToken*)tokenFromRenrenResponse:(NSURL*)url;

#pragma mark storage
+ (id)tokenFromDefaultKeychainWithServiceProviderName:(NSString *)provider;
- (void)storeInDefaultKeychainWithServiceProviderName:(NSString *)provider;
- (void)removeFromDefaultKeychainWithServiceProviderName:(NSString *)provider;

+ (NSString *)serviceNameWithProvider:(NSString *)provider;
@end
