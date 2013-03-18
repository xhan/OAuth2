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
//@property(copy,nonatomic) NSString*otherInfo;
@property(readonly,nonatomic) BOOL isExpired;

@property(retain,nonatomic) NSMutableDictionary*info;  // remember to save info with archive-friendly object
@property(copy,nonatomic)   NSString*provider;  // alias of the provider
@property(readonly) NSTimeInterval exipresAtUTC;

- (id)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiresDuration:(int)duration scope:(NSSet *)scope;
- (void)save;


#pragma mark storage
+ (id)tokenFromDefaultKeychainWithServiceProviderName:(NSString *)provider;
- (void)storeInDefaultKeychainWithServiceProviderName:(NSString *)provider;
- (void)removeFromDefaultKeychainWithServiceProviderName:(NSString *)provider;

+ (NSString *)serviceNameWithProvider:(NSString *)provider;


- (void)addInfo:(NSObject*)obj forKey:(NSString*)key;
@end
