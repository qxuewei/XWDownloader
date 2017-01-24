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
@interface XWDownloader : NSObject

@property (nonatomic, assign) XWDownloadState state;

/**
 根据URL地址下载资源, 如果任务已经存在, 则执行继续动作
 */
-(void)downloader:(NSURL *)url;
/**
 暂停任务
 注意:
 - 如果调用了几次继续
 - 调用几次暂停, 才可以暂停
 - 解决方案: 引入状态
 */
- (void)pauseCurrentTask;

/**
 取消任务
 */
- (void)cacelCurrentTask;

/**
 取消任务, 并清理资源
 */
- (void)cacelAndClean;


@end
