//
//  OAEngine.h
//  OAuth2
//
//  Created by xu xhan on 2/25/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuth2AccessToken.h"
#import "OAuth2AuthorizeWebView.h"

typedef enum{
    OAuthProviderSina,
    OAuthProviderRenRen
}OAuthProvider;

@interface OAEngine : NSObject<OAuth2AuthorizeWebViewDelegate>
{
    OAuth2AccessToken *tokenSina, *tokenRenRen;
}
- (BOOL)isLogined:(OAuthProvider)provider;
- (BOOL)isValid:(OAuthProvider)provider;

- (void)authorizedSina;
- (void)authorizedRenren;

@property(retain,nonatomic) OAuth2AccessToken*tokenSina;
@property(retain,nonatomic) OAuth2AccessToken*tokenRenRen;
@end
