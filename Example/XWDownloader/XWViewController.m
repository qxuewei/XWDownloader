//
//  XWViewController.m
//  XWDownloader
//
//  Created by Xuewei on 01/20/2017.
//  Copyright (c) 2017 Xuewei. All rights reserved.
//

#import "XWViewController.h"
#import "XWDownloader.h"

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
    [self timer];
}

- (IBAction)download:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"];
    [self.downLoader downloader:url];
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
