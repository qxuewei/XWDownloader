//
//  XWFileTool.m
//  XWDownloader
//
//  Created by 邱学伟 on 2017/1/20.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import "XWFileTool.h"

@implementation XWFileTool
+(NSString *)cachaPath{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}
+(NSString *)documentPath{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}
+(NSString *)temporaryPath{
    return NSTemporaryDirectory();
}
+(BOOL)fileExists:(NSString *)filePath{
    if (filePath.length == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
+(long long)fileSize:(NSString *)filePath{
    if (![self fileExists:filePath]) {
        return 0;
    }
    NSError *error;
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"计算文件大小出错:%@",error);
        return 0;
    }else{
        return [fileInfo[NSFileSize] longLongValue];
    }
}
+(void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath{
    if (![self fileSize:fromPath]) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}
+(void)removeFile:(NSString *)filePath{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
@end
