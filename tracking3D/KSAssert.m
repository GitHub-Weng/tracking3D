//
//  KSAssert.m
//  QQKSong
//
//  Created by vectorwang on 14-5-22.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "KSAssert.h"

void AssertBreakProintCall(const char* pszFile, const char* pszFunction, unsigned long iLine)
{
    // do while 防止被优化
    // 写代码的时候在这里下一个断点。
    do {
        // release 版本会打印关键信息出来
#ifndef DEBUG
        NSString* strAssert = [NSString stringWithFormat:@"%s, %s:%lu", pszFunction, pszFile, iLine];
        NSString* strToLog = [NSString stringWithFormat:@"*** Assertion failure in (%@).", strAssert];
        NSLog(strToLog);
#endif
    } while (0);
}