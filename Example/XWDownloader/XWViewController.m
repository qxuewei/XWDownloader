//
//  XWViewController.m
//  XWDownloader
//
//  Created by Xuewei on 01/20/2017.
//  Copyright (c) 2017 Xuewei. All rights reserved.
//

#import "XWViewController.h"
#import "XWDownloaderManager.h"

@interface XWViewController ()
@property (nonatomic, strong) XWDownloader *downLoader;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation XWViewController
-(XWDownloader *)downLoader{
    if(!_downLoader){
        _downLoader = [[XWDownloader alloc] init];
    }
    return _downLoader;
}
-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(printState) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
-(void)printState{
    NSLog(@"self.downLoader.state: ++++  %zd",self.downLoader.state);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self timer];
}

- (IBAction)download:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"];
    NSURL *url2 = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/network/Thunder302.dmg"];
    XWDownloaderManager *mgr1 = [XWDownloaderManager shareInstance];
    [mgr1 downloader:url downloadInfo:^(long long totalSize) {
        NSLog(@"++++ 任务1 +  totalSize: %lld ",totalSize);
    } stateChange:^(XWDownloadState state) {
        NSLog(@"++++ 任务1 +  state: %zd ",state);
    } progressChange:^(float progress) {
        NSLog(@"++++ 任务1 + progress: %f ",progress);
    } downloadSuccess:^(NSString *filePath) {
        NSLog(@"++++ 任务1 +  filePath: %@ ",filePath);
    } downloadFailed:^(NSError *error) {
        NSLog(@"++++ 任务1 +  error: %@ ",error);
    }];
    XWDownloaderManager *mgr2 = [XWDownloaderManager new];
    [mgr2 downloader:url2 downloadInfo:^(long long totalSize) {
        NSLog(@"++++ 任务2 +  totalSize: %lld ",totalSize);
    } stateChange:^(XWDownloadState state) {
        NSLog(@"++++ 任务2 +  state: %zd ",state);
    } progressChange:^(float progress) {
        NSLog(@"++++ 任务2 +  progress: %f ",progress);
    } downloadSuccess:^(NSString *filePath) {
        NSLog(@"++++ 任务2 +  filePath: %@ ",filePath);
    } downloadFailed:^(NSError *error) {
        NSLog(@"++++ 任务2 +  error: %@ ",error);
    }];
    
}
- (IBAction)pause:(id)sender {
    [self.downLoader pauseCurrentTask];
}
- (IBAction)cancel:(id)sender {
    [self.downLoader cacelCurrentTask];
}
- (IBAction)cancelClean:(id)sender {
    [self.downLoader cacelAndClean];
}

@end
