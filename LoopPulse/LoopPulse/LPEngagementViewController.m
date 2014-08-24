//
//  LPEngagementViewController.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/24/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPEngagementViewController.h"

@interface LPEngagementViewController ()
@property (nonatomic, retain) LPEngagement *engagement;
@end

@implementation LPEngagementViewController

- (id)initWithEngagement:(LPEngagement *)engagement
{
    self = [super init];
    if (self) {
        _engagement = engagement;
    }
    return self;
}

- (void)loadView
{
    // TODO: encapsulate in LPEngagementView
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    // TODO: Should handle status bar properly.
    // https://developer.apple.com/library/ios/qa/qa1797/_index.html#//apple_ref/doc/uid/DTS40013765
    UIWebView *engagementView = [[UIWebView alloc] initWithFrame:appFrame];
    engagementView.delegate = self;
    engagementView.scalesPageToFit = YES;
    engagementView.scrollView.scrollEnabled = NO;
    engagementView.scrollView.bounces = NO;

    NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [engagementView loadRequest:request];

    self.view = engagementView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
