//
//  OAuth2AccessToken.m
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OA2AccessToken.h"
//#import "JSONKit.h"

@implementation OA2AccessToken
@synthesize scope,expiresAt,accessToken,refreshToken, otherInfo;

- (void)dealloc
{
    PLSafeRelease(scope);
    PLSafeRelease(expiresAt);
    PLSafeRelease(accessToken);
    PLSafeRelease(refreshToken);
    PLSafeRelease(otherInfo);
    [super dealloc];
}

- (id)initWithAccessToken:(NSString *)_accessToken refreshToken:(NSString *)_refreshToken expiresDuration:(int)duration scope:(NSSet *)_scope
{
    self = [super init];
    if (self) {
        self.accessToken = _accessToken;
        self.refreshToken = _refreshToken;
        if (duration) {
            NSDate* dateExpired = [[NSDate date] dateByAddingTimeInterval:duration];
            self.expiresAt = dateExpired;
        }
        self.scope = _scope;
    }
    return self;
}

- (BOOL)isExpired
{
    return self.expiresAt && [[NSDate date] earlierDate:self.expiresAt] == self.expiresAt;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:accessToken forKey:@"accessToken"];
	[aCoder encodeObject:refreshToken forKey:@"refreshToken"];
	[aCoder encodeObject:expiresAt forKey:@"expiresAt"];
    [aCoder encodeObject:scope forKey:@"scope"];
    [aCoder encodeObject:otherInfo forKey:@"otherInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
	if (self) {
		accessToken = [[aDecoder decodeObjectForKey:@"accessToken"] copy];
		refreshToken = [[aDecoder decodeObjectForKey:@"refreshToken"] copy];
		expiresAt = [[aDecoder decodeObjectForKey:@"expiresAt"] copy];
        scope = [[aDecoder decodeObjectForKey:@"scope"] copy];
        otherInfo = [[aDecoder decodeObjectForKey:@"otherInfo"] copy];
	}
	return self;
}

/*
+ (OA2AccessToken*)tokenFromSinaResponse:(NSData*)data
{
//    NSString* contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    {"access_token":"2.00kXyBoB0yd2Nfcdd789eb500c2gPb","expires_in":86400,"remind_in":"18251","uid":"1655420692"}
    NSDictionary*dict = [data objectFromJSONData];
    NSString* token = [dict objectForKey:@"access_token"];
    int expired = [[dict objectForKey:@"expires_in"] intValue];
    NSString* other = [dict objectForKey:@"uid"];
    if (token && expired && other) {
        OA2AccessToken* instance = [[OA2AccessToken alloc] initWithAccessToken:token
                                                                     refreshToken:nil
                                                                  expiresDuration:expired
                                                                            scope:nil];
        instance.otherInfo = other;
        return [instance autorelease];
    }else {
        return nil;
    }
    
}
+ (OA2AccessToken*)tokenFromRenrenResponse:(NSURL*)url
{
    return nil;
}
 */

#pragma mark storage

+ (NSString *)serviceNameWithProvider:(NSString *)provider
{
    NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
	return [NSString stringWithFormat:@"%@::OAuth2::%@", appName, provider];
}
+ (id)tokenFromDefaultKeychainWithServiceProviderName:(NSString *)provider
{
    NSString *serviceName = [[self class] serviceNameWithProvider:provider];
	NSDictionary *result = nil;
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (NSString *)kSecClassGenericPassword, kSecClass,
						   serviceName, kSecAttrService,
						   kCFBooleanTrue, kSecReturnAttributes,
						   nil];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
	[result autorelease];
	
	if (status != noErr) {
		NSAssert1(status == errSecItemNotFound, @"unexpected error while fetching token from keychain: %d", status);
		return nil;
	}
    id obj = nil;
	@try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[result objectForKey:(NSString *)kSecAttrGeneric]];
    }
    @catch (NSException *exception) {
        //something wrong here, might caused by changed class name. oops
    }
	return obj;
}
- (void)storeInDefaultKeychainWithServiceProviderName:(NSString *)provider
{
    NSString *serviceName = [[self class] serviceNameWithProvider:provider];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (NSString *)kSecClassGenericPassword, kSecClass,
						   serviceName, kSecAttrService,
						   @"OAuth 2 Access Token", kSecAttrLabel,
						   data, kSecAttrGeneric,
						   nil];
	[self removeFromDefaultKeychainWithServiceProviderName:provider];
	OSStatus __attribute__((unused)) err = SecItemAdd((CFDictionaryRef)query, NULL);
	NSAssert1(err == noErr, @"error while adding token to keychain: %d", err);
}
- (void)removeFromDefaultKeychainWithServiceProviderName:(NSString *)provider
{
    NSString *serviceName = [[self class] serviceNameWithProvider:provider];
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (NSString *)kSecClassGenericPassword, kSecClass,
						   serviceName, kSecAttrService,
						   nil];
	OSStatus __attribute__((unused)) err = SecItemDelete((CFDictionaryRef)query);
	NSAssert1((err == noErr || err == errSecItemNotFound), @"error while deleting token from keychain: %d", err);
}
@end
