//
//  OAViewController.m
//  OAuth2
//
//  Created by xu xhan on 2/24/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAViewController.h"



#import "PLHttpBlock.h"

#import "OAEngine.h"
#import "OA2AccessToken.h"
@interface OAViewController ()

@end



@implementation OAViewController
{
    PLHttpBlock* client;
    OAEngine*engine;
}

@synthesize webview;

- (id)init
{
    self  = [super init];
    return self;
}

- (IBAction)onSina:(id)sender
{
    [engine authorizedSina];
}

- (IBAction)onRenren:(id)sender
{
    [engine authorizedRenren];
}

- (IBAction)onQQ:(id)sender {
    [engine authorizedQQ];
}

- (IBAction)onQQPost:(id)sender {
}

- (IBAction)onWeiboPost:(id)sender {
    /*    
    1. 直接使用参数传递参数名为 access_token https://api.weibo.com/2/statuses/public_timeline.json?access_token=abcd
    2. 在header里传递 形式为在header里添加Authorization:OAuth2空格abcd 这里的abcd假定为Access Token的值
     */

//    https://api.weibo.com/2/statuses/update.json
    /*
    NSDictionary*dict = @{@"access_token":engine.tokenSina.accessToken,@"status":@"test from oauth2"};
    NSString* params = [PLHttpClient paramsFromDict:dict];
    if (!client) {
        client = [[PLHttpBlock alloc] init];
    }
    [client post:URL(@"https://api.weibo.com/2/statuses/update.json")
            body:params ok:^(id ok){NSLog(@"ok");} fail:^(NSError*e){NSLog(@"failed %@",e);}];
     */
}

- (IBAction)onPostRR:(id)sender {
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    engine = [[OAEngine alloc] init];
    NSLog(@"sina %d, renren %d qq %d",[engine isValid:OAProviderSina],[engine isValid:OAProviderRenRen],
          [engine isValid:OAProviderQQ]);    
}




- (void)viewDidUnload
{
    [self setWebview:nil];
    [super viewDidUnload];
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
