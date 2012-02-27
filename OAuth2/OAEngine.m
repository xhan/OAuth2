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
#define kOARRAuthURL @"https://graph.renren.com/oauth/authorize?response_type=token&display=touch"
#define kOARRTokenURL @"https://graph.renren.com/oauth/token"
#define kOARRRedirect @"http://graph.renren.com/oauth/login_success.html"


//#error "Define key first"
//#if defined (kOA2SinaKey) && defined (kOA2SinaSecret)
 

#define ProviderNameSina @"sina"
#define ProviderNameRenRen @"renren"

@interface OAEngine(/*Private*/)
- (NSURL*)requestURL:(OAProvider)provider;
- (BOOL)handleSinaResponse:(NSData*)data;
- (BOOL)handleRenRenResponse:(NSURL*)url;

- (void)requestToken:(OAProvider)provider code:(NSString*)code;
@end


@implementation OAEngine

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

#pragma mark - delegate

- (void)authorizeWebView:(OA2AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code
{
    //don't have cancel action
    NSLog(@"%@",code);
    // just for sina now...
    [self requestToken:type code:code];
}




#pragma mark - private

- (NSURL*)requestURL:(OAProvider)provider
{
    if (provider == OAProviderSina) {
        NSDictionary*dict = @{@"response_type":@"code",
                              @"redirect_uri":kOASinaRedirect,
                              @"client_id":kOASinaKey
                            };
        NSURL* url = URL(kOASinaAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else if (provider == OAProviderRenRen){
        /*
        http://graph.renren.com/oauth/authorize?display=touch&response_type=token&redirect_uri=http%3A%2F%2Fwidget.renren.com%2Fcallback.html&ua=18da8a1a68e2ee89805959b6c8441864&client_id=f74f74797e644ee49e35f407092f6ec5
         */
        NSDictionary*dict = @{@"response_type":@"token",
        @"redirect_uri":kOARRRedirect,
        @"client_id":kOARRKey
        };
        NSURL* url = URL(kOARRAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else {        
        return nil;
    }
}

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


@end
