//
//  BaseViewController.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 06/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#define IS_EMPTY_STR(x) (x == nil || [x isEqualToString: @""])
//至少拿到空串，不能是nil
#define SAFE_GETSTR(x) x ? x:@""

/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

// 机型
#define IS_IPHONE5_OR_LATER (([[UIScreen mainScreen] bounds].size.height-568 >= 0) ? YES : NO)
#define IS_IPHONE6_OR_LATER (([[UIScreen mainScreen] bounds].size.height-667 >= 0) ? YES : NO)
#define IS_IPHONE6          (([[UIScreen mainScreen] bounds].size.height-667)?NO:YES)
#define IS_IPHONE6_PLUS     (([[UIScreen mainScreen] bounds].size.height-736)?NO:YES)
#define IS_IPHONE4          (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)
#define IS_IPHONE5          (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_7    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
#define IS_OS_8    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_OS_91_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.1)
#define IS_OS_90            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 9.1)

#define IS_OS_10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IS_OS_11_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)

#define LARGE_THAN_X   (([[UIScreen mainScreen] bounds].size.height - 812 > 0) ? YES : NO )
#define LARGE_THAN_6PLUS   (([[UIScreen mainScreen] bounds].size.height - 736 > 0) ? YES : NO )
#define LARGE_THAN_6   (([[UIScreen mainScreen] bounds].size.height - 667 > 0) ? YES : NO )
#define LARGE_THAN_5   (([[UIScreen mainScreen] bounds].size.height - 568 > 0) ? YES : NO )
#define LARGE_THAN_4   (([[UIScreen mainScreen] bounds].size.height - 480 > 0) ? YES : NO )

#define SMALL_THAN_6PLUS   (([[UIScreen mainScreen] bounds].size.height - 736 < 0) ? YES : NO )
#define SMALL_THAN_6   (([[UIScreen mainScreen] bounds].size.height - 667 < 0) ? YES : NO )
#define SMALL_THAN_5   (([[UIScreen mainScreen] bounds].size.height - 568 < 0) ? YES : NO )


/* 
 如果有些边距需要在三种屏幕下有不同的值，用这个宏
 在iPhone4~iPhone5s上面，会返回ip5s这个值
 在iPhone6上面返回ip6，在iPhone6 Plus上面返回ip6p
*/
#define DYNAMIC_MARGIN(ip5s, ip6, ip6p) (LARGE_THAN_6 ? (ip6p) : (LARGE_THAN_5 ? (ip6) : (ip5s)))

#define DYNAMIC_VALUE(ip4, ip5, ip6, ip6p)  (LARGE_THAN_6 ? (ip6p): (LARGE_THAN_5 ? (ip6): (LARGE_THAN_4 ? (ip5): (ip4))))

#define DYNAMIC_VALUE_UNIVERSAL(ip4, ip5, ip6, ip6p , bigger)  (LARGE_THAN_X ? (bigger): (LARGE_THAN_6 ? (ip6p): (LARGE_THAN_5 ? (ip6): (LARGE_THAN_4 ? (ip5) : (ip4)))))
/*
 在不同的机型上加载不同的资源
*/
#define DYNAMIC_IMAGE(ip4, ip5, ip6, ip6p)  (IS_IPHONE6_PLUS ? (ip6p): (IS_IPHONE6 ? (ip6): (IS_IPHONE5 ? (ip5): (ip4))))

/*
 在不同机型上设置不同的字体，plus*1.5
 */
#define DYNAMIC_FONT(ip,ip6p) (IS_IPHONE6_PLUS?(ip6p):(ip))
// 位置，大小
#define STATUS_BAR_ISHIDDEN [UIApplication sharedApplication].statusBarHidden

//出现热点的时候这个值返回的是40 布局不要使用这个 用上面的 写死大小
//#define STATUS_BAR_HEIGHT   CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])

#define SCREEN_WIDTH  CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT ((STATUS_BAR_ISHIDDEN || IS_OS_7_OR_LATER) ? CGRectGetHeight([[UIScreen mainScreen] bounds]):(CGRectGetHeight([[UIScreen mainScreen] bounds]) - STATUS_BAR_HEIGHT))
#define KS_ADAPT_WIDTH(x) (kScreenWidth / 320.0 * (x))

#define IsIPhoneX (CGRectGetWidth([[UIScreen mainScreen] bounds]) == 375.f && CGRectGetHeight([[UIScreen mainScreen] bounds]) == 812.f ? YES : NO)
#define STATUS_BAR_HEIGHT (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))

#define iPhoneXSafeAreaBottom 34.f
#define iPhoneXSafeAreaTop 44.f
#define SCREEN_SAFE_TOP (STATUS_BAR_HEIGHT)
#define SCREEN_SAFE_BOTTOM (IsIPhoneX ? iPhoneXSafeAreaBottom : 0)


// width of the screen in portrait-orientation
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// height of the screen in portrait-orientation
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define KSTabBarHeight (IS_OS_7_OR_LATER ? (IsIPhoneX ? (49 + 34.f) : 49) : 50)

//宽度适配
#define KS_ADAPT_WIDTH(x) (kScreenWidth / 320.0 * (x))
#define QZ_ADAPT_WIDTH(x) (kScreenWidth / 320.0 * (x))

#define KS_ADAPT6_WIDTH(x) (kScreenWidth / 375.0 * (x))


//#define COM_STATUS_HEIGHT 20
#define COM_NAV_HEIGHT 44
#define COM_TAB_HEIGHT 49
#define STATUSBAR_HEIGHT_FIX    (IS_OS_7_OR_LATER?0:20)

#define IMAGENAMED(x) [UIImage imageNamed:x]

//界面元素的一些通用限制
//最大昵称长度
#define MAX_NICKLEN 36
#define kMinUploadImageWidth 100
#define kMinUploadImageHeight 100

//controller里允许存在的vc的最大数
#define kMaxVCCountInContrller 20


// http response header key
//#define HTTP_RESPONSE_HEADER_KEY_SERVER_CHECK @"Server-Check"
#define HTTP_RESPONSE_HEADER_KEY_CONTENT_RANGE @"Content-Range"
#define HTTP_RESPONSE_HEADER_KEY_CONTENT_LENGTH @"Content-Length"

#define SAFE_CAST(obj, asClass)  [ComHelper safeCastObject:(obj) toClass:[asClass class]]


#define TIMESTAMP [[NSDate date] timeIntervalSince1970]

#define min(a, b) ((a)>(b)?(b):(a))
#define max(a, b) ((a)>(b)?(a):(b))

#define RETURN_X_IF_NIL(obj, x) ((obj) ? (obj) : (x))

#define ALERT_BUTTON_TITLE_KNOWN KString(@"我知道了")

#define FLOAT_ALMOST_ZERO 1e-6

// == Begin == 创建单例代码

#define DECLARE_SINGLETON_FOR_CLASS(classname, accessorname)    \
+ (classname *)accessorname;                                    

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname, accessorname) \
+ (classname *)accessorname                                     \
{                                                               \
    static classname *accessorname = nil;                       \
    static dispatch_once_t onceToken;                           \
    dispatch_once(&onceToken, ^{                                \
        accessorname = [[classname alloc] init];                \
    });                                                         \
    return accessorname;                                        \
}


#define DEFEND_NIL_2VARS(var1, var2)   \
if ((!var1) || (!var2))                \
{                                      \
    return;                            \
}                                      \

#define DEFEND_NIL_3VARS(var1, var2, var3)  \
if ((!var1) || (!var2) || (!var3))          \
{                                           \
    return;                                 \
}                                           \

#define CALL_COMPELTION_BLOCK(blockName, var1, var2)  \
if (blockName)                                        \
{                                                     \
    blockName(var1, var2);                            \
}                                                     \
// ==  End  == 创建单例代码


