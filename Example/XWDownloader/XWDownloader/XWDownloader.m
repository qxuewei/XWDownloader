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
}
@property (nonatomic, copy) NSString *downloadedPath;
@property (nonatomic, copy) NSString *downloadingPath;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOutputStream *stream;

@end

@implementation XWDownloader

-(NSURLSession *)session{
    if(!_session){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

-(void)downloader:(NSURL *)url{
    NSString *fileName = url.lastPathComponent;
    self.downloadedPath = [[XWFileTool cachaPath] stringByAppendingPathComponent:fileName];
    self.downloadingPath = [[XWFileTool temporaryPath] stringByAppendingPathComponent:fileName];
    
    if ([XWFileTool fileExists:self.downloadedPath]) {
        NSLog(@"to 下载完成");
        return;
    }
    
    if (![XWFileTool fileExists:self.downloadingPath]) {
        NSLog(@"to 从0字节开始下载");
        [self downloadWithURL:url offset:0];
        return;
    }
    
    _tempSize = [XWFileTool fileSize:_downloadingPath];
    [self downloadWithURL:url offset:_tempSize];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        request.HTTPMethod = @"HEAD";
//        NSHTTPURLResponse *response = nil;
//        NSError *error = nil;
//        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        if (!error) {
//            NSLog(@"response:%@",response.allHeaderFields[@"Content-Length"]);
//        }
}

#pragma mark - NSURLSessionDataDelegate
/// 第一次接收到响应头信息
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    _totalSize = [response.allHeaderFields[@"Content-Range"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length > 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    if (_tempSize < _totalSize) {
        self.stream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
        [self.stream open];
        completionHandler(NSURLSessionResponseAllow);
    }else if (_tempSize == _totalSize){
        [XWFileTool moveFile:self.downloadingPath toPath:self.downloadedPath];
        completionHandler(NSURLSessionResponseCancel);
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
    NSLog(@"接收数据---");
    [self.stream write:data.bytes maxLength:data.length];
}
/// 请求完成
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) {
        NSLog(@"请求完成");
        
    }else{
        NSLog(@"请求出错:error:%@",error);
    }
    [self.stream close];
}


#pragma mark - 私有
-(void)downloadWithURL:(NSURL *)url offset:(long long)offset{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [dataTask resume];
}
@end
