//
//  OAEngine.h
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OA2AccessToken.h"
#import "OA2AuthorizeWebView.h"

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
#define kOASinaRedirect @"http://app.qiushibaike.com"

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


typedef enum{
    OAProviderQQ = 0,
    OAProviderSina = 1,
    OAProviderRenRen = 2,
    OAProviderWeiXin = 3,
}OAProvider;

#import "PLHttpClient.h"

@protocol OAuth2WebAuthorizeDelegate <NSObject>

- (void)setOAuthView:(UIWebView *)autherView OAProvider:(OAProvider)provider;

@end

@interface OAEngine : NSObject<OAuth2AuthorizeWebViewDelegate>
{
    OA2AccessToken *tokenSina, *tokenRenRen, *tokenQQ, *tokenWX;
    PLHttpClient*client;
    int type;   //current action type;
    BOOL isSaveTokenToDisk;
}
- (BOOL)isLogined:(OAProvider)provider;
- (BOOL)isValid:(OAProvider)provider;
- (void)logout:(OAProvider)provider;
- (void)authorizedSina;
- (void)authorizedRenren;
- (void)authorizedQQ;
- (void)authorize:(OAProvider)provider;
- (void)authorize:(OAProvider)provider save2disk:(BOOL)save;
- (BOOL)authorizeSSO:(OAProvider)provider;
- (BOOL)authorizeWeb:(OAProvider)provider;
- (void)reloadTokens;

@property(retain,nonatomic) OA2AccessToken*tokenSina;
@property(retain,nonatomic) OA2AccessToken*tokenRenRen;
@property(retain,nonatomic) OA2AccessToken*tokenQQ;
@property(retain,nonatomic) OA2AccessToken*tokenWX;
@property(nonatomic,retain) OA2AccessToken*tokenLatest;
@property(nonatomic, assign) id<OAuth2WebAuthorizeDelegate> delegate;

+ (void)addNotify:(id)target sel:(SEL)selector;
+ (void)rmNotify:(id)target;
+ (void)handleNotifyInfo:(NSDictionary*)info
                  result:(void (^)(OAProvider,BOOL,id))result;
- (void)postNotify:(OAProvider)provider success:(BOOL)success;


- (BOOL)handleOpenURL:(NSURL*)url;

- (OA2AccessToken*)accessToken:(OAProvider)p;
- (void)setToken:(OA2AccessToken*)token forProvider:(OAProvider)provider save:(BOOL)save;

- (void)handleWXLogin:(NSString *)code;

@end
