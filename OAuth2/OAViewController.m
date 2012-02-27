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

- (void)viewDidLoad
{
    [super viewDidLoad];
    engine = [[OAEngine alloc] init];
    NSLog(@"sina %d, renren %d",[engine isValid:OAProviderSina],[engine isValid:OAProviderRenRen]);    
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
