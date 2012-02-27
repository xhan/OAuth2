//
//  OAEngine.m
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAEngine.h"


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
- (NSURL*)requestURL:(OAuthProvider)provider;
@end


@implementation OAEngine

- (id)init
{
    self = [super init];
    if (self) {
        self.tokenSina = [OAuth2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameSina];
        self.tokenRenRen = [OAuth2AccessToken tokenFromDefaultKeychainWithServiceProviderName:ProviderNameRenRen];
    }
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

- (BOOL)isLogined:(OAuthProvider)provider
{
    if (provider == OAuthProviderSina) {
        return !!self.tokenSina;
    }else if (provider == OAuthProviderRenRen) {
        return !!self.tokenRenRen;
    }else {
        return NO;
    }
    
}
- (BOOL)isValid:(OAuthProvider)provider
{
    if (provider == OAuthProviderSina) {
        return self.tokenSina && !self.tokenSina.isExpired;
    }else if (provider == OAuthProviderRenRen) {
        return self.tokenRenRen && !self.tokenRenRen.isExpired;
    }else {
        return NO;
    }
    
}

- (void)authorizedSina
{
    OAuth2AuthorizeWebView*view = [[OAuth2AuthorizeWebView alloc] init];
    view.type = OAuthProviderSina;
    view.delegate = self;
    [view loadRequestWithURL:[self requestURL:OAuthProviderSina]];
    [view show:YES];
    [view release];
}
- (void)authorizedRenren
{
    OAuth2AuthorizeWebView*view = [[OAuth2AuthorizeWebView alloc] init];
    view.type = OAuthProviderRenRen;
    view.delegate = self;
    [view loadRequestWithURL:[self requestURL:OAuthProviderRenRen]];
    [view show:YES];
    [view release];
}

#pragma mark - delegate

- (void)authorizeWebView:(OAuth2AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code
{
    //don't have cancel action
    NSLog(@"%@",code);
}




#pragma mark - private

- (NSURL*)requestURL:(OAuthProvider)provider
{
    if (provider == OAuthProviderSina) {
        NSDictionary*dict = @{@"response_type":@"code",
                              @"redirect_uri":kOASinaRedirect,
                              @"client_id":kOASinaKey
                            };
        NSURL* url = URL(kOASinaAuthURL);
        return [url urlByaddingParamsDict:dict];
    }else if (provider == OAuthProviderRenRen){
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
@end
