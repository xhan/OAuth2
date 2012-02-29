//
//  WBAuthorizeWebView.h
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OA2AuthorizeWebView;

@protocol OAuth2AuthorizeWebViewDelegate <NSObject>
@optional
- (void)authorizeWebView:(OA2AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code;
- (BOOL)authorizeWebView:(OA2AuthorizeWebView *)webView shouldHandleURL:(NSURL*)url;
@end

@interface OA2AuthorizeWebView : UIView <UIWebViewDelegate> 
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
    id<OAuth2AuthorizeWebViewDelegate> delegate;
    UIButton* closeBtn;
}

@property (nonatomic, assign) id<OAuth2AuthorizeWebViewDelegate> delegate;
@property (assign, nonatomic) int type;
- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

//- (BOOL)sinaHandleURLChange:(NSURL*)url;
//- (BOOL)renrenHandleURLChange:(NSURL*)url;


@end