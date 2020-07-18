//
//  WDWebView.m
//  WDWebViewController
//
//  Created by pactera on 2018/2/24.
//  Copyright © 2018年 pactera_hui. All rights reserved.
//

#import "WDWebView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation WDWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration viewController:(UIViewController *)controler webviewType:(WDWebViewType)type webUrlString:(NSString *)urlString
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
        self.mWebView.allowsBackForwardNavigationGestures = YES;
        self.mWebView.UIDelegate = self;
        self.mWebView.navigationDelegate = self;
        self.mWebView.allowsLinkPreview = YES;
        //self.mWebView.customUserAgent = @"WebViewDemo/1.0.0";
        self.mWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.mWebView setValue:[NSValue valueWithUIEdgeInsets:self.mWebView.scrollView.contentInset] forKey:@"_obscuredInsets"];
        
        if (type == WDWebViewTypeURL) {
            NSURL *webUrl = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:webUrl];
            [self.mWebView loadRequest:request];
        }else{
            NSString *urlStr = [[NSBundle mainBundle] pathForResource:urlString ofType:nil];
            NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
            [self.mWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        }

        [self addSubview:self.mWebView];
        self.viewControler = controler;
        
//        [self.mWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
//        [self initProgressView];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)controler webviewType:(WDWebViewType)type webUrlString:(NSString *)urlString
{
    self = [super initWithFrame:frame];
    if (self) {
        [self clearWbCache];
        //1. 初始化偏好设置属性：preferences
        WKPreferences *preferences = [WKPreferences new];
        //是否支持JavaScript
        preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        //The minimum font size in points default is 0;
        preferences.minimumFontSize = 4.0;
        self.preferences = preferences;
        
        // 2. 通过JS与WKUserContentController内容交互
        WKUserContentController *userContentController = [WKUserContentController new];
        self.userContentController = userContentController;
        
        // 3. WKWebView 添加配置文件
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences = preferences;
        configuration.userContentController = userContentController;
        //// web内容处理池
        configuration.processPool = [[WKProcessPool alloc] init];
        
        //设置HTML5视频是否允许网页播放 设置为false则会使用本地播放器
        configuration.allowsInlineMediaPlayback = YES;

        configuration.mediaPlaybackAllowsAirPlay = YES;
        
        // //设置视频是否需要用户手动播放  设置为false则会允许自动播放
        //#warning mark Deprecated(ios10)
        //configuration.requiresUserActionForMediaPlayback = false;
        //2019年01月03日13:59:16 add by zhangya
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
            configuration.requiresUserActionForMediaPlayback = NO;
        } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
            configuration.mediaPlaybackRequiresUserAction = NO;
        }

        self.configuration = configuration;
        
        CGRect webFrame = CGRectMake(frame.origin.x,0, frame.size.width, frame.size.height);
        self.mWebView = [[WKWebView alloc] initWithFrame:webFrame configuration:configuration];
        //self.mWebView.allowsBackForwardNavigationGestures = YES;
        [self.mWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.mWebView setNavigationDelegate:self];
        [self.mWebView setUIDelegate:self];
        [self.mWebView setMultipleTouchEnabled:YES];
        [self.mWebView setAutoresizesSubviews:YES];
        [self.mWebView.scrollView setAlwaysBounceVertical:YES];
        self.mWebView.scrollView.bounces = NO;
        
        // 4. WKWebView 初始化
        if (@available(iOS 9.0, *)) {
            self.mWebView.allowsLinkPreview = YES;
            NSString *userAgent = [self userAgentString];
//            self.mWebView.customUserAgent = userAgent;
        }else{
            
        }
        self.mWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.mWebView setValue:[NSValue valueWithUIEdgeInsets:self.mWebView.scrollView.contentInset] forKey:@"_obscuredInsets"];
        
        if (type == WDWebViewTypeURL) {
            NSURL *webUrl = [NSURL URLWithString:urlString];
            if (!webUrl.scheme) {
                webUrl = [NSURL URLWithString:@""];
            }
            
            NSURLRequest * urlReuqest = [[NSURLRequest alloc]initWithURL:webUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
            [self.mWebView loadRequest:urlReuqest];
        }else{
            NSString *urlStr = [[NSBundle mainBundle] pathForResource:urlString ofType:nil];
            NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
            [self.mWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        }
        [self addSubview:self.mWebView];
        
        self.viewControler = controler;
        
//        [self.mWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
//        [self initProgressView];
        
        
    }
    return self;
}


- (NSString *)userAgentString{
    NSString *userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if TARGET_OS_IOS
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif TARGET_OS_WATCH
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; watchOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[WKInterfaceDevice currentDevice] model], [[WKInterfaceDevice currentDevice] systemVersion], [[WKInterfaceDevice currentDevice] screenScale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        return userAgent;
    }
    return userAgent;
}

/**
 清理缓存
 */
- (void)clearWbCache {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        
        NSSet *websiteDataTypes
        
        = [NSSet setWithArray:@[
                                WKWebsiteDataTypeDiskCache,
                                
                                //WKWebsiteDataTypeOfflineWebApplicationCache,
                                
                                WKWebsiteDataTypeMemoryCache,
                                
                                //WKWebsiteDataTypeLocalStorage,
                                
                                //WKWebsiteDataTypeCookies,
                                
                                //WKWebsiteDataTypeSessionStorage,
                                
                                //WKWebsiteDataTypeIndexedDBDatabases,
                                
                                //WKWebsiteDataTypeWebSQLDatabases
                                ]];
        
        //// All kinds of data
        
        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        //// Date from
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        //// Execute
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
            // Done
            
        }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        
        NSError *errors;
        
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}


- (void)initProgressView
{
    CGFloat progressViewWidth = [[UIScreen mainScreen] bounds].size.width;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, progressViewWidth, 1)];
//    progressView.tintColor = UIColorFromRGB(0x737989);
    progressView.trackTintColor = [UIColor clearColor];
    progressView.tintColor = UIColorFromRGB(0x5481F1);
    [self addSubview:progressView];
    self.progressView = progressView;
}

#pragma mark -
#pragma mark - WDWebViewDelegate

#pragma mark - WKUIDelegate
///如果需要显示提示框,则需要实现以下代理
//alert 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self.viewControler presentViewController:alert animated:YES completion:nil];
    
}

//confirm 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self.viewControler presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:@"调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self.viewControler presentViewController:alert animated:YES completion:NULL];
}



#pragma mark - WKNavigationDelegate
/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.wdWebViewDelegate respondsToSelector:@selector(wd_WebView:didStartProvisionalNavigation:)]) {
        [self.wdWebViewDelegate wd_WebView:webView didStartProvisionalNavigation:navigation];
    }
}
/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if ([self.wdWebViewDelegate respondsToSelector:@selector(wd_webView:didCommitNavigation:)]) {
        [self.wdWebViewDelegate wd_webView:webView didCommitNavigation:navigation];
    }
}

/// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    if ([self.wdWebViewDelegate respondsToSelector:@selector(wd_webView:didFinishNavigation:)]) {
        [self.wdWebViewDelegate wd_webView:webView didFinishNavigation:navigation];
    }
}
/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if ([self.wdWebViewDelegate respondsToSelector:@selector(wd_webView:didFailNavigation:withError:)]) {
        [self.wdWebViewDelegate wd_webView:webView didFailNavigation:navigation withError:error];
    }
}


// js-->oc Url拦截 在发送请求之前，决定是否跳转
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
//    NSURL *URL = navigationAction.request.URL;
//    NSString *scheme = [URL scheme];
//    if ([scheme isEqualToString:@"http"]) {
//        decisionHandler(WKNavigationActionPolicyCancel);
//        return;
//    }else if ([scheme isEqualToString:@"https"]) {
//
//        if ([self.wdWebViewDelegate respondsToSelector:@selector(wd_WebView:urlHostString:decidePolicyForNavigationAction:decisionHandler:)]) {
//            [self.wdWebViewDelegate wd_WebView:webView urlHostString:[URL host] decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
//        }
//        decisionHandler(WKNavigationActionPolicyAllow);
//        return;
//
//    }
//    decisionHandler(WKNavigationActionPolicyAllow);
//}
//// 在收到响应后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}

// WKScriptMessageHandler JS-->OC 回调
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.wdWebViewDelegate respondsToSelector:@selector(wd_UserContentController:didReceiveScriptMessage:)]) {
        WDWebModel *messageModel = [[WDWebModel alloc] init];
        messageModel.name = message.name;
        messageModel.body = message.body;
        
        [self.wdWebViewDelegate wd_UserContentController:userContentController didReceiveScriptMessage:messageModel];
    }
}
#pragma mark -
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.mWebView && [keyPath isEqualToString:@"estimatedProgress"])
    {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1)
        {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}
#pragma mark --> 向JS 注册/移除 OC方法(JS调OC)
- (void)wd_AddScriptMessageHandler:(NSString *)scriptMessageHandler
{
    [self wd_RemoveScriptMessageHandler:scriptMessageHandler];
    [self.mWebView.configuration.userContentController addScriptMessageHandler:self name:scriptMessageHandler];
}

- (void)wd_RemoveScriptMessageHandler:(NSString *)scriptMessageHandler
{
    [self.mWebView.configuration.userContentController removeScriptMessageHandlerForName:scriptMessageHandler];
}
#pragma mark - JS 注入 (OC调JS)
- (void)wd_EvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError * error))completionHandler
{
    [self.mWebView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        completionHandler(result,error);
    }];
}

#pragma mark - 刷新webview
- (void)reloadData
{
    [self.mWebView reload];
}

- (void)dealloc
{
    [self.mWebView setNavigationDelegate:nil];
    [self.mWebView setUIDelegate:nil];
    [self.mWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    NSLog(@"WDWebView dealloc !!!");
}
@end
