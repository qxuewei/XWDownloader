//
//  NSString+MD5.m
//  XWDownloader
//
//  Created by 邱学伟 on 2017/2/3.
//  Copyright © 2017年 Xuewei. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (MD5)
-(NSString *)MD5{
    const char *UTF8String = self.UTF8String;
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    CC_MD5(UTF8String, (CC_LONG)strlen(UTF8String), md);
    NSMutableString *md5Result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Result appendFormat:@"%02x",md[i]];
    }
    return md5Result;
}
@end
