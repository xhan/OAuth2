//
//  OAEngine.m
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAEngine.h"
#import "JSONKit.h"

#define kOASinaKey @"609011242"
#define kOASinaSecret @"f5b209105c1735f86cc7324fed6873b5"

#define kOARRKey   @"f74f74797e644ee49e35f407092f6ec5"
#define kOARRSecret @"15e6644eec424855acd99ce9a551c0da"

// sina buildin
#define kOASinaAuthURL @"https://api.weibo.com/oauth2/authorize?display=mobile"
#define kOASinaTokenURL @"https://api.weibo.com/oauth2/access_token"
#define kOASinaRedirect @"app://test.com"

// renren buildin
#define kOARRAuthURL @"https://graph.renren.com/oauth/authorize?display=touch"
//touch
//response_type=token&
#define kOARRTokenURL @"https://graph.renren.com/oauth/token"
#define kOARRRedirect @"http://graph.renren.com/oauth/login_success.html"


//#error "Define key first"
//#if defined (kOA2SinaKey) && defined (kOA2SinaSecret)
#define OAEngineNotify @"OAEngineNotify" 

#define ProviderNameSina @"sina"
#define ProviderNameRenRen @"renren"

@interface OAEngine(/*Private*/)
- (NSURL*)requestURL:(OAProvider)provider;
//- (BOOL)handleSinaResponse:(NSData*)data;
//- (BOOL)handleRenRenResponse:(NSURL*)url;

//- (void)requestToken:(OAProvider)provider code:(NSString*)code;
+ (NSDictionary *)parseURLParams:(NSString *)query;


//return YES if found token in url
- (BOOL)handleTokenURL:(OAProvider)provider url:(NSURL*)url;
@end


@implementation OAEngine
@synthesize tokenSina, tokenRenRen;
- (id)init
{
    self = [super init];
    if (self) {
        self.tokenSina = [OA2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameSina];
        self.tokenRenRen = [OA2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameRenRen];
    }
    return self;
}

- (void)dealloc
{
    PLSafeRelease(client);
    [super dealloc];
}

- (BOOL)isLogined:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        return !!self.tokenSina;
    }else if (provider == OAProviderRenRen) {
        return !!self.tokenRenRen;
    }else {
        return NO;
    }
    
}
- (BOOL)isValid:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        return self.tokenSina && !self.tokenSina.isExpired;
    }else if (provider == OAProviderRenRen) {
        return self.tokenRenRen && !self.tokenRenRen.isExpired;
    }else {
        return NO;
    }
    
}

- (void)authorizedSina
{
    type = OAProviderSina;
    OA2AuthorizeWebView*view = [[OA2AuthorizeWebView alloc] init];
    view.type = OAProviderSina;
    view.delegate = self;
    [view loadRequestWithURL:[self requestURL:OAProviderSina]];
    [view show:YES];
    [view release];
}
- (void)authorizedRenren
{
    type = OAProviderRenRen;
    OA2AuthorizeWebView*view = [[OA2AuthorizeWebView alloc] init];
    view.type = OAProviderRenRen;
    view.delegate = self;
    [view loadRequestWithURL:[self requestURL:OAProviderRenRen]];
    [view show:YES];
    [view release];
}

- (void)logout:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        [self.tokenSina removeFromDefaultKeychainWithServiceProviderName:ProviderNameSina];
        self.tokenSina = nil;
    }else if (provider == OAProviderRenRen ) {
        [self.tokenRenRen removeFromDefaultKeychainWithServiceProviderName:ProviderNameRenRen];
        self.tokenRenRen = nil;
    }
    [self postNotify:provider success:NO];
}

- (BOOL)handleTokenURL:(OAProvider)provider url:(NSURL*)url
{
    //app://test.com#access_token=2.00kXyBoB0yd2Nf6412fc65e6tDDJgC&expires_in=86400&remind_in=75265&uid=1655420692
    
    /*
     http://graph.renren.com/oauth/login_success.html#access_token=180804%7C6.bc641538f1992e2c1b56e98ccbe5ba2f.2592000.1332921600-200218453&expires_in=2595468&scope=read_user_album+status_update+photo_upload+publish_feed+create_album+operate_like
     */

    NSDictionary* params = [[self class] parseURLParams:[url fragment]];
    NSString* token = [params objectForKey:@"access_token"];
    int expired= [[params objectForKey:@"expires_in"] intValue];
    
    if ([token isNonEmpty] && expired) {
        PLOG(@"token(exp:%d) %@",expired,token);
        OA2AccessToken* accessToken = [[OA2AccessToken alloc] initWithAccessToken:token
                                                                refreshToken:nil
                                                             expiresDuration:expired
                                                                       scope:nil];
        if (provider == OAProviderSina) {
            self.tokenSina = accessToken;
            [self.tokenSina storeInDefaultKeychainWithServiceProviderName:ProviderNameSina];
        }else if(provider == OAProviderRenRen){
            self.tokenRenRen = accessToken;
            [self.tokenRenRen storeInDefaultKeychainWithServiceProviderName:ProviderNameRenRen];
        }
        return YES;
    }else {
        return NO;
    }

}

#pragma mark - delegate
/*
- (void)authorizeWebView:(OA2AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code
{
    //don't have cancel action
    NSLog(@"%@",code);
    // just for sina now...
    [self requestToken:type code:code];
}
*/

- (BOOL)authorizeWebView:(OA2AuthorizeWebView *)webView shouldHandleURL:(NSURL*)url
{
    // app://test.com#error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330
    // http ://graph.renren.com/oauth/login_success.html#error=login_denied&error_description=The+end-user+denied+logon.
    
    
    // user cancel handle
    BOOL canceled = NO;
    if (type == OAProviderSina) {
        canceled = [url.absoluteString rangeOfString:@"error_code=21330"].location != NSNotFound;
    }else if (type == OAProviderRenRen) {
        canceled = [url.absoluteString rangeOfString:@"error=login_denied"].location != NSNotFound;
    }
    if (canceled) {
        [webView hide:YES];
        return NO;
    }
    
    // check if got token in url
    BOOL isTokenGoted = [self handleTokenURL:type url:url];
    if (isTokenGoted) {
//        NSLog(@"got token !!!!!!!");
        [webView hide:YES];
        [self postNotify:type success:YES];
        return NO;
    }else {        
        [self postNotify:type success:NO];
        return YES;
    }
    
}



#pragma mark - private

+ (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            NSString *val =[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
	}
    return [params autorelease];
}

- (NSURL*)requestURL:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        //code | token
        /*
        NSDictionary*dict = @{@"response_type":@"token",
                              @"redirect_uri":kOASinaRedirect,
                              @"client_id":kOASinaKey
                            };
         */
        NSDictionary*dict = PLDict(@"token",@"response_type",
                                   kOASinaRedirect,@"redirect_uri",
                                   kOASinaKey, @"client_id");
        NSURL* url = URL(kOASinaAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else if (provider == OAProviderRenRen){
        /*
        NSDictionary*dict = @{@"response_type":@"token",
        @"redirect_uri":kOARRRedirect,
        @"client_id":kOARRKey
        };
         */
        NSDictionary*dict = PLDict(@"token",@"response_type",
                                   kOARRRedirect,@"redirect_uri",
                                   kOARRKey,@"client_id");
        NSURL* url = URL(kOARRAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else {        
        return nil;
    }
}

/*
- (BOOL)handleSinaResponse:(NSData*)data
{
    OA2AccessToken*token = [OA2AccessToken tokenFromSinaResponse:data];
    if (token) {
        self.tokenSina = token;
        [self.tokenSina storeInDefaultKeychainWithServiceProviderName:ProviderNameSina];
    }
    return !!token;
}

- (BOOL)handleRenRenResponse:(NSURL*)url
{
    return NO;
}


- (void)requestToken:(OAProvider)provider code:(NSString*)code
{
    if (!client) {
        client = [[PLHttpClient alloc] init];
        client.delegate = self;
    }
    [client cancel];
    if (provider == OAProviderSina) {
        NSDictionary*params = [NSDictionary dictionaryWithObjectsAndKeys:kOASinaKey,@"client_id",
                               kOASinaSecret,@"client_secret",
                               @"authorization_code", @"grant_type",
                               kOASinaRedirect,@"redirect_uri",
                               code, @"code",nil];
                            
        NSURL* url = URL(kOASinaTokenURL);
        [client post:url
                body:[PLHttpClient paramsFromDict:params]];
    }else if(provider == OAProviderRenRen){
        NSLog(@"not finished");
    }
}

 */

/*
#pragma mark - http delegate

- (void)httpClient:(PLHttpClient *)hc failed:(NSError *)error
{
    //post notification
    NSLog(@"failed!!!! !!!!!!! %@",error);
}

- (void)httpClient:(PLHttpClient *)hc successed:(NSData *)data
{
    BOOL result = [self handleSinaResponse:data];
    if (!result) {
        NSError* err = [NSError errorWithDomain:@"oauth2.error" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"parse content error",NSLocalizedDescriptionKey, nil]];
        [self httpClient:hc failed:err];
    }else {
        //post notification
        NSLog(@"got !!!!!!!");
    }
}
*/


+ (void)addNotify:(id)target sel:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] 
     addObserver:target
     selector:selector
     name:OAEngineNotify
     object:nil];
}
+ (void)rmNotify:(id)target
{
    [[NSNotificationCenter defaultCenter] 
     removeObserver:target
     name:OAEngineNotify
     object:nil];         
}

+ (void)handleNotifyInfo:(NSDictionary*)info
                  result:(void (^)(OAProvider,BOOL))result
{
    int provider = [[info objectForKey:@"p"] intValue];
    BOOL success = [[info objectForKey:@"ret"] boolValue]; 
    if (result) {
        result(provider,success);
    }
    
}

- (void)postNotify:(OAProvider)provider success:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:OAEngineNotify 
     object:self
     userInfo:PLDict(NUM(provider),@"p",NUM(success),@"ret")];
}
@end
