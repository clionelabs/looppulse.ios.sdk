//
//  LPEngagementViewController.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/24/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPEngagementViewController.h"

@interface LPEngagementViewController ()
@property (nonatomic, retain) NSDictionary *engagementInfo;
@end

@implementation LPEngagementViewController

- (id)initWithEngagement:(NSDictionary *)engagementInfo
{
    self = [super init];
    if (self) {
        _engagementInfo = engagementInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its

    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:appFrame];
//    NSLog(@"appFrame: x %d, y %d, w %d h %d",
//          (int)appFrame.origin.x,
//          (int)appFrame.origin.y,
//          (int)appFrame.size.width,
//          (int)appFrame.size.height);
//    UIWebView *webView = [[UIWebView alloc] init];
    [webView setAutoresizesSubviews:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    webView.delegate = self;

    NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentEngagement
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootVC = window.rootViewController;
    [rootVC presentViewController:self animated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError: %@", error);
}


@end
