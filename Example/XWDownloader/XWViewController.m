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

@end

@implementation XWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    XWDownloader *downloader = [[XWDownloader alloc] init];
    [downloader downloader:[NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"]];
}

@end
