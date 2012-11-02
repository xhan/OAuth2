//
//  OAViewController.h
//  OAuth2
//
//  Created by xu xhan on 2/24/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAViewController : UIViewController<UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *webview;
//- (void)handleCode:(NSString*)code;
- (IBAction)onSina:(id)sender;
- (IBAction)onRenren:(id)sender;
- (IBAction)onWeiboPost:(id)sender;
- (IBAction)onPostRR:(id)sender;
- (IBAction)onQQ:(id)sender;
- (IBAction)onQQPost:(id)sender;

@end
