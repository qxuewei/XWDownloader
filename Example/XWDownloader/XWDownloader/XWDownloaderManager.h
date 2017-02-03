//
//  XWDownloaderManager.h
//  XWDownloader
//
//  Created by 邱学伟 on 2017/2/3.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDownloader.h"
@interface XWDownloaderManager : NSObject
-(void)downloader:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo stateChange:(StateChangeBlock)stateChange progressChange:(ProgressChangeBlock)progressChange downloadSuccess:(DownloadSuccessBlock)downloadSuccess downloadFailed:(DownloadFailedBlock)downloadFailed;

@end
