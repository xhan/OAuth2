//
//  OAuth2AccessToken.m
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OA2AccessToken.h"

@implementation OA2AccessToken
@synthesize scope,expiresAt,accessToken,refreshToken, info,provider=_provider;

- (void)dealloc
{
    PLSafeRelease(scope);
    PLSafeRelease(expiresAt);
    PLSafeRelease(accessToken);
    PLSafeRelease(refreshToken);
//    PLSafeRelease(otherInfo);
    PLSafeRelease(info);
    PLSafeRelease(_provider);
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

- (NSTimeInterval)exipresAtUTC
{
    if (self.expiresAt) {
        return [self.expiresAt timeIntervalSince1970];
    }else{
        return 0;
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:accessToken forKey:@"accessToken"];
	[aCoder encodeObject:refreshToken forKey:@"refreshToken"];
	[aCoder encodeObject:expiresAt forKey:@"expiresAt"];
    [aCoder encodeObject:scope forKey:@"scope"];
    [aCoder encodeObject:info forKey:@"info"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
	if (self) {
		accessToken = [[aDecoder decodeObjectForKey:@"accessToken"] copy];
		refreshToken = [[aDecoder decodeObjectForKey:@"refreshToken"] copy];
		expiresAt = [[aDecoder decodeObjectForKey:@"expiresAt"] copy];
        scope = [[aDecoder decodeObjectForKey:@"scope"] copy];
        info = [[NSMutableDictionary alloc] initWithDictionary:[aDecoder decodeObjectForKey:@"info"]];
	}
	return self;
}

- (void)addInfo:(NSObject*)obj forKey:(NSString*)key
{
    if (!self.info) {
        self.info = [NSMutableDictionary dictionary];
    }
    (self.info)[key] = obj;
}

#pragma mark storage

- (void)save
{
    if (self.provider) {
        [self removeFromDefaultKeychainWithServiceProviderName:self.provider];
        [self storeInDefaultKeychainWithServiceProviderName:self.provider];
    }
}

+ (NSString *)serviceNameWithProvider:(NSString *)provider
{
    NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
	return [NSString stringWithFormat:@"%@::OAuth2::%@", appName, provider];
}
+ (id)tokenFromDefaultKeychainWithServiceProviderName:(NSString *)provider
{
    NSString *serviceName = [[self class] serviceNameWithProvider:provider];
	NSDictionary *result = nil;
	NSDictionary *query = @{(id)kSecClass: (NSString *)kSecClassGenericPassword,
						   (id)kSecAttrService: serviceName,
						   (id)(id)kSecReturnAttributes: (id)kCFBooleanTrue};
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
	[result autorelease];
	
	if (status != noErr) {
		NSAssert1(status == errSecItemNotFound, @"unexpected error while fetching token from keychain: %ld", status);
		return nil;
	}
    OA2AccessToken* obj = nil;
	@try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:result[(NSString *)kSecAttrGeneric]];
        obj.provider = provider;
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
	NSDictionary *query = @{(id)kSecClass: (NSString *)kSecClassGenericPassword,
						   (id)kSecAttrService: serviceName,
						   (id)kSecAttrLabel: @"OAuth 2 Access Token",
						   (id)kSecAttrGeneric: data};
	[self removeFromDefaultKeychainWithServiceProviderName:provider];
	OSStatus __attribute__((unused)) err = SecItemAdd((CFDictionaryRef)query, NULL);
	NSAssert1(err == noErr, @"error while adding token to keychain: %ld", err);
}
- (void)removeFromDefaultKeychainWithServiceProviderName:(NSString *)provider
{
    NSString *serviceName = [[self class] serviceNameWithProvider:provider];
	NSDictionary *query = @{(id)kSecClass: (NSString *)kSecClassGenericPassword,
						   (id)kSecAttrService: serviceName};
	OSStatus __attribute__((unused)) err = SecItemDelete((CFDictionaryRef)query);
	NSAssert1((err == noErr || err == errSecItemNotFound), @"error while deleting token from keychain: %ld", err);
}
@end
