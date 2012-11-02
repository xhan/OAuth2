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

typedef enum{
    OAProviderQQ = 0,
    OAProviderSina = 1,
    OAProviderRenRen = 2    
}OAProvider;

#import "PLHttpClient.h"

@interface OAEngine : NSObject<OAuth2AuthorizeWebViewDelegate>
{
    OA2AccessToken *tokenSina, *tokenRenRen, *tokenQQ;
    PLHttpClient*client;
    int type;   //current action type;
}
- (BOOL)isLogined:(OAProvider)provider;
- (BOOL)isValid:(OAProvider)provider;
- (void)logout:(OAProvider)provider;
- (void)authorizedSina;
- (void)authorizedRenren;
- (void)authorizedQQ;
- (void)authorize:(OAProvider)provider;
- (void)reloadTokens;

@property(retain,nonatomic) OA2AccessToken*tokenSina;
@property(retain,nonatomic) OA2AccessToken*tokenRenRen;
@property(retain,nonatomic) OA2AccessToken*tokenQQ;

+ (void)addNotify:(id)target sel:(SEL)selector;
+ (void)rmNotify:(id)target;
+ (void)handleNotifyInfo:(NSDictionary*)info
                  result:(void (^)(OAProvider,BOOL))result;
- (void)postNotify:(OAProvider)provider success:(BOOL)success;


- (BOOL)handleOpenURL:(NSURL*)url;

@end
