//
//  XWDownloaderManager.m
//  XWDownloader
//
//  Created by 邱学伟 on 2017/2/3.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import "XWDownloaderManager.h"

@implementation XWDownloaderManager
-(void)downloader:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo stateChange:(StateChangeBlock)stateChange progressChange:(ProgressChangeBlock)progressChange downloadSuccess:(DownloadSuccessBlock)downloadSuccess downloadFailed:(DownloadFailedBlock)downloadFailed{
    XWDownloader *downloader = [[XWDownloader alloc] init];
    [downloader downloader:url downloadInfo:downloadInfo stateChange:stateChange progressChange:progressChange downloadSuccess:downloadSuccess downloadFailed:downloadFailed];
}
@end
