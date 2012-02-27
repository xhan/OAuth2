//
//  OAViewController.m
//  OAuth2
//
//  Created by xu xhan on 2/24/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAViewController.h"


#import "OAuth2AccessToken.h"
#import "OAuth2AuthorizeWebView.h"

#import "PLHttpBlock.h"
@interface OAViewController ()

@end

//#define RR_ID @"f74f74797e644ee49e35f407092f6ec5"
//#define RR_S  @"15e6644eec424855acd99ce9a551c0da"
//#define RR_



@implementation OAViewController
{
    PLHttpBlock* client;
}

@synthesize webview;

- (id)init
{
    self  = [super init];

    
    return self;
}


- (void)handleCode:(NSString*)code
{
    client = [[PLHttpBlock alloc] init];

    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"609011242", @"client_id",
                            @"f5b209105c1735f86cc7324fed6873b5", @"client_secret",
                            @"authorization_code", @"grant_type",
                            @"app://test.com", @"redirect_uri",
                            code, @"code", nil];
    
    NSURL* url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    [client post:url 
            body:[PLHttpBlock stringFromDictionary:params]
              ok:^(NSString*content){
        NSLog(@"%@",content);
    }fail:^(NSError*e){
        NSLog(@"%@",e); 
    }];

    
}

- (IBAction)onSina:(id)sender
{
    NSString*a = @"https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&redirect_uri=app%3A%2F%2Ftest.com&client_id=609011242";
    NSURL*url = [NSURL URLWithString:a];
    
    OAuth2AuthorizeWebView*view = [[OAuth2AuthorizeWebView alloc] init];
    view.type = 1;
    view.delegate = self;
    [view loadRequestWithURL:url];
    [view show:YES];
    [view release];
}

- (void)authorizeWebView:(OAuth2AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code
{
    NSLog(@"%@",code);
    [self handleCode:code]; // 21330 -> cancel
}


- (IBAction)onRenren:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webview.delegate = self;
    
/*
    
    NSString*a = @"https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&redirect_uri=app%3A%2F%2Ftest.com&client_id=609011242";
    NSURL*url = [NSURL URLWithString:a];
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
*/

}




- (void)viewDidUnload
{
    [self setWebview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [webview release];
    [super dealloc];
}
@end
