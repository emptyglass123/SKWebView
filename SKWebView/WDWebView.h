//
//  WDWebView.h
//  WDWebViewController
//
//  Created by pactera on 2018/2/24.
//  Copyright © 2018年 pactera_hui. All rights reserved.
//

// 1.初始化webview  两种方式
// 2.页面显示和消失的方法里 注册/移除js方法
// 3.可以在控制器中注册 WKWebView的代理,并实现协议方法


#import <WebKit/WebKit.h>
#import "WDWebModel.h"

typedef NS_ENUM(NSInteger, WDWebViewType) {
    WDWebViewTypeLocal,  // 本地资源
    WDWebViewTypeURL     // 网络资源
};
@class WDWebView;

@protocol WDWebViewDelegate <NSObject>

/// 页面开始加载时的代理
- (void)wd_WebView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

/// 当内容开始返回时调用的代理
- (void)wd_webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

/// 页面加载完成之后调用的代理
- (void)wd_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

/// 页面加载失败时调用的代理
- (void)wd_webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error;

@optional

/**
 js --> oc

 @param userContentController WKUserContentController
 @param message WKScriptMessage
 */
- (void)wd_UserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WDWebModel *)message;



/**
 js  --> oc 拦截URL方式实现

 @param webView WKWebView
 @param urlStr 拦截处理结果
 @param navigationAction WKNavigationAction
 @param decisionHandler block
 */
- (void)wd_WebView:(WKWebView *)webView urlHostString:(NSString *)urlStr decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
@end


@interface WDWebView : UIView <WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, weak) id<WDWebViewDelegate> wdWebViewDelegate;
@property (nonatomic, assign) WDWebViewType mWebViewType;
@property (nonatomic, strong) WKWebView *mWebView;
@property (nonatomic, strong) WKPreferences *preferences;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIViewController *viewControler;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;


/**
 初始化方法

 @param frame 坐标
 @param configuration WKWebViewConfiguration
 @param controler 底层控制器
 @param type html类型  WDWebViewTypeLocal,本地资源  WDWebViewTypeURL,网络资源
 @param urlString url地址
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration viewController:(UIViewController *)controler webviewType:(WDWebViewType)type webUrlString:(NSString *)urlString;


/**
 初始化方法

 @param frame 坐标
 @param controler 底层控制器
 @param type html类型  WDWebViewTypeLocal,本地资源  WDWebViewTypeURL,网络资源
 @param urlString url地址
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)controler webviewType:(WDWebViewType)type webUrlString:(NSString *)urlString;


/**
 注册js内部的方法

 @param scriptMessageHandler 方法名称
 */
- (void)wd_AddScriptMessageHandler:(NSString *)scriptMessageHandler;


/**
 移除注册的js内部方法

 @param scriptMessageHandler 方法名称
 */
- (void)wd_RemoveScriptMessageHandler:(NSString *)scriptMessageHandler;


/**
 oc --> js方法

 @param javaScriptString js方法名(可包含参数)
 @param completionHandler block回调
 */
- (void)wd_EvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError * error))completionHandler;


/**
 刷新webView数据
 */
- (void)reloadData;






@end
