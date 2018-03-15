//
//  NSString+Extern.h
//  QQMusic
//
//  Created by verazeng on 13-10-9.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Extern)
- (NSArray *)rangesOfSubString:(NSString *)subString;
- (NSString *)stringByReversed;
- (NSString *)safe_SubstringWithRange:(NSRange)aRange;
- (NSString *)safe_SubstringFromIndex:(NSUInteger)index;
- (NSString *)safe_SubstringToIndex:(NSUInteger)index;
- (BOOL)isNumberString;
- (BOOL)isInsensitiveSubstringOfString:(NSString *)string;


- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;


+ (NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding;

+ (NSString *)generateUuidString;
- (BOOL)isEmpty;
- (NSString *)trimWhitespace;


/*
 计算字符串的text unit个数。
 emoji表情、国旗、汉字等做为一个text unit处理，避免表情截断.
 注意国旗长度为4，需要两次rangeOfComposedCharacterSequenceAtIndex才能读取完，所以需要stringIsInBlackList辅助处理
 */

- (NSUInteger)charactersCount;


/*
 从string中起始位置开始返回包含最多不越过maxCount个 text unit 的子串.
 emoji表情、国旗、汉字等做为一个text unit处理，避免表情截断.
 注意国旗长度为4，需要两次rangeOfComposedCharacterSequenceAtIndex才能读取完，所以需要stringIsInBlackList辅助处理

 所有使用：[name substringToIndex:count]的地方，当 name 可能包含 emoji 等表情时，都需要替换为如下：[name substringWithinMaxlength:count]
 */

//- (NSString*)getSubstringWithinMaxCount:(NSUInteger) maxCount;

/*
 从string中起始位置开始返回包含最多不越过maxCount个 text unit 的子串.
 emoji表情、国旗、汉字等做为一个text unit处理，避免表情截断.
 注意国旗长度为4，需要两次rangeOfComposedCharacterSequenceAtIndex才能读取完，所以需要stringIsInBlackList辅助处理
 
 所有使用：[name substringToIndex:count]的地方，当 name 可能包含 emoji 等表情时，都需要替换为如下：[name substringWithinMaxlength:count]
 */

//- (NSString*)getSubstringWithinMaxCount:(NSUInteger) maxCount;

// 对一个url添加parameter，如果是第二个及以上的parameter，则要加的格式为&parameter
- (NSString *)urlStringByAppendingParameter:(NSString *)parameter;



@end
