//
//  ViewController.m
//  WebKitDemo
//
//  Created by zjsruxxxy3 on 15/5/2.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import "ViewController.h"

@import WebKit;

@interface ViewController ()<UITextFieldDelegate ,WKNavigationDelegate>// webView新的代理
{
}
@property (weak, nonatomic) IBOutlet UIView *barBackgroundView;

@property(nonatomic,strong)WKWebView *webView;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextField *inputURLField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fowardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)stopReload:(id)sender;
@end

@implementation ViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.webView = [[WKWebView alloc]initWithFrame:CGRectZero];


    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.barBackgroundView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, 30);
    
    self.webView.navigationDelegate = self;

    [self.view addSubview:self.webView];
    
    [self.view insertSubview:self.webView belowSubview:self.progressView];
    
    _backButton.enabled = NO;
    _fowardButton.enabled = NO;
    
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:Nil];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:Nil];
    
    [self.progressView setProgress:0 animated:NO];
    
    [self setupWebViewWithConstraint];
    
    [self setupWebViewWithRequest];

    
}

#pragma webView 的 KVO实现
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    _backButton.enabled = [self.webView canGoBack];
    
    _fowardButton.enabled = [self.webView canGoForward];
    
    if([keyPath isEqualToString:@"loading"])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    }
    
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.progressView.hidden = (self.webView.estimatedProgress == 1.0);
        
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }
}
/**
 *   设置webView的布局
 */
-(void)setupWebViewWithConstraint
{

    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *widthConstrain = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:.0];
    
    NSLayoutConstraint *heightConstrain = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-44.0];
    
    [self.view addConstraints:@[widthConstrain,heightConstrain]];
}

/**
 *   webView加载网络请求
 */
-(void)setupWebViewWithRequest
{
    self.inputURLField.text = @"http://www.baidu.com";
    
    NSURL *url = [NSURL URLWithString:self.inputURLField.text];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

#pragma mark webViewDelegate
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s",__func__);

}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"%@----",navigationAction.request);
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:Nil];
    
    
}

//  请求加载结束后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.progressView setProgress:0.0 animated:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
#pragma mark textFielDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];

    self.navigationItem.rightBarButtonItem = cancelButton;
    
}
-(void)cancel:(id)sender
{
    [self.inputURLField resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.barBackgroundView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 30);
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.inputURLField resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.barBackgroundView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 30);

    NSLog(@"%@",self.inputURLField.text);
    
    NSURL *url = [NSURL URLWithString:self.inputURLField.text];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:urlRequest];
    
    return false;
}

//  旋转时调用的方法
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.barBackgroundView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 30);
    
}

- (IBAction)goBack:(id)sender {
    [self.webView goBack];
    
}

- (IBAction)goForward:(id)sender {
    [self.webView goForward];
    
}

- (IBAction)stopReload:(id)sender {
    
    if (self.webView.loading)
    {
        [self.webView stopLoading];
    }else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.webView.URL];

        [self.webView loadRequest:request];
        
    }
    
}
@end
