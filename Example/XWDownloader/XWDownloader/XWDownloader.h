//
//  XWDownloader.h
//  XWDownloader
//
//  Created by 邱学伟 on 2017/1/20.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, XWDownloadState) {
    XWDownloadStatePause,      
    XWDownloadStateDownloading,
    XWDownloadStateSuccess,
    XWDownloadStateFailed
};

// 数据传递block类型
typedef void(^DownloadInfoBlock)(long long totalSize);
typedef void(^StateChangeBlock)(XWDownloadState state);
typedef void(^ProgressChangeBlock)(float progress);
typedef void(^DownloadSuccessBlock)(NSString *filePath);
typedef void(^DownloadFailedBlock)(NSError *error);

@interface XWDownloader : NSObject
/// 下载状态
@property (nonatomic, assign, readonly) XWDownloadState state;
/// 下载进度
@property (nonatomic, assign, readonly) float progress;
/// 下载数据总大小
@property (nonatomic, copy) DownloadInfoBlock downloadInfo;
/// 当前下载状态
@property (nonatomic, copy) StateChangeBlock stateChange;
/// 当前下载进度
@property (nonatomic, copy) ProgressChangeBlock progressChange;
/// 下载成功
@property (nonatomic, copy) DownloadSuccessBlock downloadSuccess;
/// 下载失败
@property (nonatomic, copy) DownloadFailedBlock downloadFailed;
/**
 根据URL地址下载资源, 如果任务已经存在, 则执行继续动作
 */
-(void)downloader:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo stateChange:(StateChangeBlock)stateChange progressChange:(ProgressChangeBlock)progressChange downloadSuccess:(DownloadSuccessBlock)downloadSuccess downloadFailed:(DownloadFailedBlock)downloadFailed;

/**
 暂停任务
 注意:
 - 如果调用了几次继续
 - 调用几次暂停, 才可以暂停
 - 解决方案: 引入状态
 */
- (void)pauseCurrentTask;

/**
 继续任务
 - 如果调用了几次暂停, 就要调用几次继续, 才可以继续
 - 解决方案: 引入状态
 */
- (void)resumeCurrentTask;

/**
 取消任务
 */
- (void)cacelCurrentTask;

/**
 取消任务, 并清理资源
 */
- (void)cacelAndClean;


@end
