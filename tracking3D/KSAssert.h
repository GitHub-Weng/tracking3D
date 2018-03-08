//
//  KSAssert.h
//  QQKSong
//
//  Created by vectorwang on 14-5-22.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#define ASSERT(x) if(!(x)){AssertBreakProintCall(__FILE__, __FUNCTION__, __LINE__); assert(0);}

#ifdef __cplusplus
extern "C"
{
#endif
    void AssertBreakProintCall(const char* pszFile, const char* pszFunction, unsigned long iLine);
#ifdef __cplusplus
}
#endif
