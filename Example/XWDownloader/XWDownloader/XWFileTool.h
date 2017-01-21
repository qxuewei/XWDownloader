//
//  XWFileTool.h
//  XWDownloader
//
//  Created by 邱学伟 on 2017/1/20.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWFileTool : NSObject
/// cache 路径
+(NSString *)cachaPath;
/// doc 路径
+(NSString *)documentPath;
/// temp 路径
+(NSString *)temporaryPath;
/// 是否存在
+ (BOOL)fileExists:(NSString *)filePath;
/// 文件大小
+ (long long)fileSize:(NSString *)filePath;
/// 移动
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;
/// 移除
+ (void)removeFile:(NSString *)filePath;
@end
