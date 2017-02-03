//
//  XWDownloader.m
//  XWDownloader
//
//  Created by 邱学伟 on 2017/1/20.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import "XWDownloader.h"
#import "XWFileTool.h"



@interface XWDownloader ()<NSURLSessionDataDelegate>{
    long long _tempSize;
    long long _totalSize;
    NSError *_error;
}
@property (nonatomic, copy) NSString *downloadedPath;
@property (nonatomic, copy) NSString *downloadingPath;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOutputStream *stream;

@end

@implementation XWDownloader
#pragma mark - 懒加载
-(NSURLSession *)session{
    if(!_session){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

#pragma mark - 数据传递
-(void)setState:(XWDownloadState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChange) {
        self.stateChange(_state);
    }
    if (self.downloadSuccess && state == XWDownloadStateSuccess) {
        self.downloadSuccess(self.downloadedPath);
    }
    if (self.downloadFailed && state == XWDownloadStateFailed) {
        self.downloadFailed(_error);
    }
}

-(void)setProgress:(float)progress{
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(progress);
    }
}

#pragma mark - 接口
-(void)downloader:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo stateChange:(StateChangeBlock)stateChange progressChange:(ProgressChangeBlock)progressChange downloadSuccess:(DownloadSuccessBlock)downloadSuccess downloadFailed:(DownloadFailedBlock)downloadFailed{
    self.downloadInfo = downloadInfo;
    self.stateChange = stateChange;
    self.progressChange = progressChange;
    self.downloadSuccess = downloadSuccess;
    self.downloadFailed = downloadFailed;
    [self downloader:url];
}
-(void)downloader:(NSURL *)url{
    // 内部实现
    // 1. 真正的从头开始下载
    // 2. 如果任务存在了, 继续下载
    // 0. 当前任务, 肯定存在
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        // 判断当前的状态, 如果是暂停状态
        if (self.state == XWDownloadStatePause) {
            // 继续
            [self resumeCurrentTask];
            return;
        }
    }
    [self cacelCurrentTask];
    NSString *fileName = url.lastPathComponent;
    self.downloadedPath = [[XWFileTool cachaPath] stringByAppendingPathComponent:fileName];
    self.downloadingPath = [[XWFileTool temporaryPath] stringByAppendingPathComponent:fileName];
    
    if ([XWFileTool fileExists:self.downloadedPath]) {
//        NSLog(@"to 下载完成");
        self.state = XWDownloadStateSuccess;
        return;
    }
    
    if (![XWFileTool fileExists:self.downloadingPath]) {
//        NSLog(@"to 从0字节开始下载");
        [self downloadWithURL:url offset:0];
        return;
    }
    
    _tempSize = [XWFileTool fileSize:_downloadingPath];
    [self downloadWithURL:url offset:_tempSize];
}

/**
 暂停任务
 注意:
 - 如果调用了几次继续
 - 调用几次暂停, 才可以暂停
 - 解决方案: 引入状态
 */
- (void)pauseCurrentTask{
    if (self.state == XWDownloadStateDownloading) {
        [self.dataTask suspend];
        self.state = XWDownloadStatePause;
    }
}
/**
 继续任务
 - 如果调用了几次暂停, 就要调用几次继续, 才可以继续
 - 解决方案: 引入状态
 */
- (void)resumeCurrentTask {
    if (self.dataTask && self.state == XWDownloadStatePause) {
        [self.dataTask resume];
        self.state = XWDownloadStateDownloading;
    }
}

/**
 取消任务
 */
- (void)cacelCurrentTask{
    self.state = XWDownloadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

/**
 取消任务, 并清理资源
 */
- (void)cacelAndClean{
    [self cacelCurrentTask];
    [XWFileTool removeFile:self.downloadingPath];
}



#pragma mark - NSURLSessionDataDelegate
/// 第一次接收到响应头信息
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    _totalSize = [response.allHeaderFields[@"Content-Range"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length > 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    //传递给外界总大小
    if (self.downloadInfo) {
        self.downloadInfo(_totalSize);
    }
    if (_tempSize < _totalSize) {
        self.stream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
        [self.stream open];
        self.state = XWDownloadStateDownloading;
        completionHandler(NSURLSessionResponseAllow);
    }else if (_tempSize == _totalSize){
        [XWFileTool moveFile:self.downloadingPath toPath:self.downloadedPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = XWDownloadStateSuccess;
    }else{
        //1. 删除本地缓存
        [XWFileTool removeFile:self.downloadingPath];
        //2. 从0开始下载
        [self downloader:response.URL];
        //3. 取消请求
        completionHandler(NSURLSessionResponseCancel);
    }
}
/// 开始接收数据
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    _tempSize += data.length;
    self.progress = 1.0 * _tempSize / _totalSize;
    [self.stream write:data.bytes maxLength:data.length];
}
/// 请求完成
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) {
//        NSLog(@"请求完成");
        [XWFileTool moveFile:self.downloadingPath toPath:self.downloadedPath];
        self.state = XWDownloadStateSuccess;
    }else{
        _error = error;
//        NSLog(@"请求出错:error:%@ ++++ error.code:%zd ++++ error.localizedDescription:%@",error,error.code,error.localizedDescription);
        if (error.code == -999) {
            self.state = XWDownloadStatePause;
        }else{
            self.state = XWDownloadStateFailed;
        }
    }
    [self.stream close];
}


#pragma mark - 私有
-(void)downloadWithURL:(NSURL *)url offset:(long long)offset{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}
@end
