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
    OAProviderSina,
    OAProviderRenRen,
    OAProviderQQ
}OAProvider;

#import "PLHttpClient.h"

@interface OAEngine : NSObject<OAuth2AuthorizeWebViewDelegate>
{
    OA2AccessToken *tokenSina, *tokenRenRen;
    PLHttpClient*client;
    int type;   //current action type;
}
- (BOOL)isLogined:(OAProvider)provider;
- (BOOL)isValid:(OAProvider)provider;
- (void)logout:(OAProvider)provider;
- (void)authorizedSina;
- (void)authorizedRenren;

@property(retain,nonatomic) OA2AccessToken*tokenSina;
@property(retain,nonatomic) OA2AccessToken*tokenRenRen;

@end
