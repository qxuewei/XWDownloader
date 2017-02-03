//
//  XWDownloaderManager.m
//  XWDownloader
//
//  Created by 邱学伟 on 2017/2/3.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import "XWDownloaderManager.h"
#import "NSString+MD5.h"

@interface XWDownloaderManager () <NSCopying, NSMutableCopying>
@property (nonatomic, strong) NSMutableDictionary *downloadDict;
@end

@implementation XWDownloaderManager
static XWDownloaderManager *_downloaderManager;
#pragma mark - 单例对象
+(instancetype)shareInstance{
    if (!_downloaderManager) {
        _downloaderManager = [[self alloc] init];
    }
    return _downloaderManager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_downloaderManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _downloaderManager = [super allocWithZone:zone];
        });
    }
    return _downloaderManager;
}

- (id)copyWithZone:(NSZone *)zone{
    return _downloaderManager;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _downloaderManager;
}
#pragma mark - 懒加载
-(NSMutableDictionary *)downloadDict{
    if(!_downloadDict){
        _downloadDict = [[NSMutableDictionary alloc] init];
    }
    return _downloadDict;
}
#pragma mark - 接口
-(void)downloader:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo stateChange:(StateChangeBlock)stateChange progressChange:(ProgressChangeBlock)progressChange downloadSuccess:(DownloadSuccessBlock)downloadSuccess downloadFailed:(DownloadFailedBlock)downloadFailed{
    NSString *md5Url = [url.absoluteString MD5];
    XWDownloader *downloader = self.downloadDict[md5Url];
    if (!downloader) {
        downloader = [[XWDownloader alloc] init];
        self.downloadDict[md5Url] = downloader;
    }
//    [downloader downloader:url downloadInfo:downloadInfo stateChange:stateChange progressChange:progressChange downloadSuccess:downloadSuccess downloadFailed:downloadFailed];
    __weak typeof(self) weakSelf = self;
    [downloader downloader:url downloadInfo:downloadInfo stateChange:stateChange progressChange:progressChange downloadSuccess:^(NSString *filePath) {
        [weakSelf.downloadDict removeObjectForKey:md5Url];
        downloadSuccess(filePath);
    } downloadFailed:downloadFailed];
}
- (void)pauseWithURL:(NSURL *)url{
    XWDownloader *downloader = self.downloadDict[[url.absoluteString MD5]];
    [downloader pauseCurrentTask];
}
- (void)resumeWithURL:(NSURL *)url{
    XWDownloader *downloader = self.downloadDict[[url.absoluteString MD5]];
    [downloader resumeCurrentTask];
}
- (void)cancelWithURL:(NSURL *)url{
    XWDownloader *downloader = self.downloadDict[[url.absoluteString MD5]];
    [downloader cacelCurrentTask];
}
- (void)pauseAll{
    [self.downloadDict.allValues performSelector:@selector(pauseCurrentTask)];
}
- (void)resumeAll{
    [self.downloadDict.allValues performSelector:@selector(resumeCurrentTask)];
}
-(void)cancelAll{
    [self.downloadDict.allValues performSelector:@selector(cacelCurrentTask)];
}

@end
