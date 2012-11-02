//
//  OAEngine.m
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAEngine.h"
#import "JSONKit.h"


#define kSSOCallBackURL @"ugx-qb"

#define kOASinaKey @"609011242"
#define kOASinaSecret @"f5b209105c1735f86cc7324fed6873b5"

#define kOARRKey   @"f74f74797e644ee49e35f407092f6ec5"
#define kOARRSecret @"15e6644eec424855acd99ce9a551c0da"

#define kOAQQKey    @"100251437"
#define kOAQQSecret @"ada372076fe479eb3c874759f66e342c"

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

// qq buildin
#define kOAQQAuthURL @"https://graph.qq.com/oauth2.0/authorize?display=mobile"
#define kOAQQRedirect @"http://com.qsbk.app"

//#error "Define key first"
//#if defined (kOA2SinaKey) && defined (kOA2SinaSecret)
#define OAEngineNotify @"OAEngineNotify" 



#import "Settings.h"

#define ProviderNameSina NSStringADD(@"sina",AppSettings().userID)
#define ProviderNameRenRen NSStringADD(@"renren",AppSettings().userID)
#define ProviderNameQQ  NSStringADD(@"oauth2-qq",AppSettings().userID)

@interface OAEngine(/*Private*/)
- (NSURL*)requestURL:(OAProvider)provider;

//- (void)requestToken:(OAProvider)provider code:(NSString*)code;

//return YES if found token in url
- (BOOL)handleTokenURL:(OAProvider)provider url:(NSURL*)url;
@end


@implementation OAEngine
@synthesize tokenSina, tokenRenRen, tokenQQ;
- (id)init
{    
    self = [super init];
    if (self) {
        [self reloadTokens];
    }
    return self;
}

- (void)reloadTokens
{
    self.tokenSina   = [OA2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameSina];
    self.tokenRenRen = [OA2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameRenRen];
    self.tokenQQ     = [OA2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameQQ];
}

- (void)dealloc
{
    PLSafeRelease(tokenQQ);
    PLSafeRelease(tokenRenRen);
    PLSafeRelease(tokenSina);
    PLSafeRelease(client);
    [super dealloc];
}

- (BOOL)isLogined:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        return !!self.tokenSina;
    }else if (provider == OAProviderRenRen) {
        return !!self.tokenRenRen;
    }else if (provider == OAProviderQQ) {
        return !!self.tokenQQ;
    }else{
        return NO;
    }
    
}
- (BOOL)isValid:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        return self.tokenSina && !self.tokenSina.isExpired;
    }else if (provider == OAProviderRenRen) {
        return self.tokenRenRen && !self.tokenRenRen.isExpired;
    }else if (provider == OAProviderQQ) {
        return self.tokenQQ && !self.tokenQQ.isExpired;
    }else {
        return NO;
    }
    
}


- (void)authorize:(OAProvider)provider
{
    type =  provider;
    OA2AuthorizeWebView*view = [[OA2AuthorizeWebView alloc] init];
    view.type = provider;
    view.delegate = self;
    [view loadRequestWithURL:[self requestURL:provider]];
    [view show:YES];
    [view release];
}

- (void)authorizedSina
{
#define kSinaWeiboAppAuthURL_iPhone        @"sinaweibosso://login"
#define kSinaWeiboAppAuthURL_iPad          @"sinaweibohdsso://login"
    
    BOOL ssoLogined = NO;
    NSDictionary*params = @{
    @"redirect_uri":kOASinaRedirect,
    @"client_id":kOASinaKey,
    @"callback_uri":kSSOCallBackURL
    };
    //ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSURL*url = [URL(kSinaWeiboAppAuthURL_iPad) urlByaddingParamsDict:params];
        ssoLogined = [[UIApplication sharedApplication] openURL:url];
    }
    //iphone
    if (!ssoLogined) {
        NSURL*url = [URL(kSinaWeiboAppAuthURL_iPhone) urlByaddingParamsDict:params];
        ssoLogined = [[UIApplication sharedApplication] openURL:url];
    }
    //web
    if(!ssoLogined)
        [self authorize:OAProviderSina];
}


- (void)authorizedRenren
{
    [self authorize:OAProviderRenRen];
}

- (void)authorizedQQ
{
    [self authorize:OAProviderQQ];
}

- (void)logout:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        [self.tokenSina removeFromDefaultKeychainWithServiceProviderName:ProviderNameSina];
        self.tokenSina = nil;
    }else if (provider == OAProviderRenRen ) {
        [self.tokenRenRen removeFromDefaultKeychainWithServiceProviderName:ProviderNameRenRen];
        self.tokenRenRen = nil;
    }else if (provider == OAProviderQQ) {
        [self.tokenQQ removeFromDefaultKeychainWithServiceProviderName:ProviderNameQQ];
        self.tokenQQ = nil;
    }
    [self postNotify:provider success:NO];
}

- (BOOL)handleTokenURL:(OAProvider)provider url:(NSURL*)url
{
    //app://test.com#access_token=2.00kXyBoB0yd2Nf6412fc65e6tDDJgC&expires_in=86400&remind_in=75265&uid=1655420692
    
    /*
     http://graph.renren.com/oauth/login_success.html#access_token=180804%7C6.bc641538f1992e2c1b56e98ccbe5ba2f.2592000.1332921600-200218453&expires_in=2595468&scope=read_user_album+status_update+photo_upload+publish_feed+create_album+operate_like
     */

    NSDictionary* params = [NSURL parseURLParams:[url fragment]];
    return [self handleTokenDict:provider dict:params];
    


}

- (BOOL)handleTokenDict:(OAProvider)provider dict:(NSDictionary*)params
{
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
        }else if (provider == OAProviderQQ){
            self.tokenQQ = accessToken;
            [self.tokenQQ storeInDefaultKeychainWithServiceProviderName:ProviderNameQQ];
        }
        [accessToken release];
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - delegate


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
    }else if(provider == OAProviderQQ) {
        NSDictionary*dict = PLDict(@"token",@"response_type",
                                   kOAQQRedirect,@"redirect_uri",
                                   kOAQQKey,@"client_id",
                                   @"add_topic,get_user_info,add_share,add_t,add_pic_t",@"scope");
        NSURL* url = URL(kOAQQAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else {        
        return nil;
    }
}



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
     userInfo:@{@"p": @(provider),@"ret": @(success)}];
}

// sso support
- (BOOL)handleOpenURL:(NSURL*)url
{
    //TODO: need a value to store last sso type (weibo,qq,or other)
    if ([[url scheme] isEqualToString:kSSOCallBackURL]){
        //weibo
        BOOL ret = [self handleSSOWeiboURL:url];
        if(ret) [self postNotify:OAProviderSina success:YES];
        //other
        // do nothing rightnow
    }
    
    return YES;
}

- (BOOL)handleSSOWeiboURL:(NSURL*)url
{
    //ugx-qb://?remind_in=1326742&expires_in=1326742&uid=1655420692&access_token=2.00kXyBoB0yd2Nfbea97a782d0k5T85
    
    NSDictionary*params = [url params];

//    NSString *uid =          [params objectForKey:@"uid"];
    
    //TODO: store uid
    return [self handleTokenDict:OAProviderSina dict:params];

}


@end
