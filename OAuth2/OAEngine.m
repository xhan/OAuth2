//
//  OAEngine.m
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAEngine.h"
#import "JSONKit.h"


#define USING_QQ_SSO 1
#if USING_QQ_SSO
    #import <TencentOpenAPI/TencentOAuth.h>
    #import <TencentOpenAPI/QQApi.h>
#endif



#import "Settings.h"

#define ProviderNameSina NSStringADD(@"sina",AppSettings().userID)
#define ProviderNameRenRen NSStringADD(@"renren",AppSettings().userID)
#define ProviderNameQQ  NSStringADD(@"oauth2-qq",AppSettings().userID)

#define kSinaWeiboAppAuthURL_iPhone        @"sinaweibosso://login"
#define kSinaWeiboAppAuthURL_iPad          @"sinaweibohdsso://login"

#define  kQQPermissionScope @"add_topic,get_user_info,add_share,add_t,add_pic_t,check_page_fans"


@interface OAEngine(/*Private*/)
- (NSURL*)requestURL:(OAProvider)provider;


//return YES if found token in url
- (BOOL)handleTokenURL:(OAProvider)provider url:(NSURL*)url;

@end


#if USING_QQ_SSO
@interface OAEngine (Private)<TencentSessionDelegate>
@end


@implementation OAEngine
{
    TencentOAuth* _tencentOAuth;
}
#else
@implementation OAEngine
#endif

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
#if USING_QQ_SSO
    PLSafeRelease(_tencentOAuth);
#endif
    PLSafeRelease(tokenQQ);
    PLSafeRelease(tokenRenRen);
    PLSafeRelease(tokenSina);
    PLSafeRelease(_tokenLatest);
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
    [self authorize:provider save2disk:YES];
}
- (void)authorize:(OAProvider)provider save2disk:(BOOL)save
{
    isSaveTokenToDisk = save;
    
    if (![self authorizeSSO:provider]) {
        [self authorizeWeb:provider];
    }
    

}

- (BOOL)authorizeWeb:(OAProvider)provider
{
    // TODO: 网页授权界面修改
    type =  provider;
    OA2AuthorizeWebView*view = [[OA2AuthorizeWebView alloc] init];
    view.type = provider;
    view.delegate = self;
    [view loadRequestWithURL:[self requestURL:provider]];
//    [view show:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(setOAuthView:OAProvider:)])
    {
        [self.delegate performSelector:@selector(setOAuthView:OAProvider:) withObject:view withObject:provider];
    }
    [view release];
    return YES;
}

- (BOOL)authorizeSSO:(OAProvider)provider
{
    
    if (provider == OAProviderSina) {
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
        return ssoLogined;

    }else if ( provider == OAProviderQQ){
#if USING_QQ_SSO
        BOOL ret = NO;
        if ([QQApi isQQSupportApi]) {
            if (!_tencentOAuth) {
                _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kOAQQKey andDelegate:self];
            }
            ret = [_tencentOAuth authorize:[kQQPermissionScope componentsSeparatedByString:@","]
                                       inSafari:NO];
        }
        return ret;
#else
        return NO;
#endif
    }else{
        PLOGERROR(@"NOT IMPLEMENTEED SSO FOR %d",provider);
        return NO;
    }
}

- (void)authorizedSina
{
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
    self.tokenLatest = nil;
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
    NSString* token = params[@"access_token"];
    int expired= [params[@"expires_in"] intValue];
    
    if ([token isNonEmpty] && expired) {
        PLOG(@"token(exp:%d) %@",expired,token);
        OA2AccessToken* accessToken = [[OA2AccessToken alloc] initWithAccessToken:token
                                                                     refreshToken:nil
                                                                  expiresDuration:expired
                                                                            scope:nil];
        
        // insert sina uid in url
        if (provider == OAProviderSina) {
            NSString *uid =          params[@"uid"];
            if (uid) {
                [accessToken addInfo:uid forKey:@"uid"];
            }
        }
        // latest token will be sent by notification
        // a bad design :D
        self.tokenLatest = accessToken;
        
        if (isSaveTokenToDisk) {    // in other case we don't overwrite token for speicify provider
            [self setToken:self.tokenLatest forProvider:provider save:isSaveTokenToDisk];
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
                                   @"add_topic,get_user_info,add_share,add_t,add_pic_t,check_page_fans",@"scope");
        NSURL* url = URL(kOAQQAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else {        
        return nil;
    }
}


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
                  result:(void (^)(OAProvider,BOOL,id))result
{
    int provider = [info[@"p"] intValue];
    BOOL success = [info[@"ret"] boolValue];
    id accessToken = ((OAEngine*)PLHashV(info, @"self")).tokenLatest;
    if (result) {
        result(provider,success, accessToken);
    }
    
}

- (void)postNotify:(OAProvider)provider success:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:OAEngineNotify 
     object:self
     userInfo:@{@"p": @(provider),@"ret": @(success),
         @"self":self }];
}

// sso support
- (BOOL)handleOpenURL:(NSURL*)url
{
    BOOL ret;
#if USING_QQ_SSO
    // check for qq sso
    ret = [TencentOAuth HandleOpenURL:url];
    if (ret) {
        return YES;
    }
    
#endif
    
    
    //TODO: need a value to store last sso type (weibo,qq,or other)
    if ([[url scheme] isEqualToString:kSSOCallBackURL]){
        //weibo
        ret = [self handleSSOWeiboURL:url];
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
    
    return [self handleTokenDict:OAProviderSina dict:params];

}

- (OA2AccessToken*)accessToken:(OAProvider)p
{
    switch (p) {
        case OAProviderSina:
            return self.tokenSina;
        case OAProviderQQ:
            return self.tokenQQ;
        case OAProviderRenRen:
            return self.tokenRenRen;
        default:
            return nil;
    }
}

- (void)setToken:(OA2AccessToken*)token forProvider:(OAProvider)provider save:(BOOL)save
{
    NSString*providerName = nil;
    if (provider == OAProviderSina) {
        self.tokenSina = token;
        providerName = ProviderNameSina;
    }else if(provider == OAProviderRenRen){
        self.tokenRenRen = token;
        providerName = ProviderNameRenRen;
    }else if (provider == OAProviderQQ){
        self.tokenQQ = token;
        providerName = ProviderNameQQ;
    }
    if (save) {
        [token storeInDefaultKeychainWithServiceProviderName:providerName];
    }
}

#if USING_QQ_SSO
#pragma mark - qq delegate


- (void)tencentDidLogin
{
    PLOG(@"qq login logined!");
    
//    PLOG(@"%@",QQ.accessToken);
//    PLOG(@"%@",QQ.openId);
    NSString*token = _tencentOAuth.accessToken;
    NSDate*expires = _tencentOAuth.expirationDate;
    
    if(! ([token isNonEmpty] && expires) ){
        //get info failed
        return;
    }
    
    OA2AccessToken*atoken = [[OA2AccessToken alloc] initWithAccessToken:token refreshToken:nil expiresAt:expires scope:nil];
    self.tokenLatest = atoken;
    [atoken release];
    
    [self setToken:self.tokenLatest forProvider:OAProviderQQ save:isSaveTokenToDisk];
    
    
    [self postNotify:OAProviderQQ success:YES];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        PLOG(@"qq login cancel");
    }else{
        [self postNotify:OAProviderQQ success:NO];
        PostMsg(@"qq login failed");
    }
    
}


- (void)tencentDidNotNetWork
{
    PostMsg(@"qq network error");
    [self postNotify:OAProviderQQ success:NO];
}


#endif

@end
