//
//  NSString+Extern.m
//  QQMusic
//
//  Created by verazeng on 13-10-9.
//
//

#import "NSString+Extern.h"

@implementation NSString (Extern)
- (NSArray *)rangesOfSubString:(NSString *)subString
{
    NSMutableArray *rangeArray = nil;
    if (self.length > 0 && subString.length > 0) {
        rangeArray = [NSMutableArray array];
        NSString *remainString = self;
        NSRange nextRange = [remainString rangeOfString:subString options:NSCaseInsensitiveSearch];
        while (remainString.length > 0 && nextRange.length > 0) {
            NSRange lastRange = nextRange;
            nextRange.location += (self.length - remainString.length);
            [rangeArray addObject:[NSValue valueWithRange:nextRange]];
            remainString = [remainString substringFromIndex:lastRange.location + lastRange.length];
            nextRange = [remainString rangeOfString:subString];
        }
        if (rangeArray.count == 0) {
            rangeArray = nil;
        }
    }
    return rangeArray;
}

- (NSString *)stringByReversed{
    if (self.length <= 0) {
        return self;
    }
    NSUInteger i = 0;
    NSUInteger j = self.length - 1;
    //  unichar characters[self.length];
    unichar *characters = malloc(sizeof([self characterAtIndex:0]) * self.length);
    if (characters == NULL) {
        return self;
    }
    while (i < j) {
        characters[j] = [self characterAtIndex:i];
        characters[i] = [self characterAtIndex:j];
        i ++;
        j --;
    }
    if(i == j) {
        characters[i] = [self characterAtIndex:i];
    }
    NSString *ret = [NSString stringWithCharacters:characters length:self.length];
    free(characters);
    return ret;
}

- (NSString *)safe_SubstringWithRange:(NSRange)aRange
{
    /*
    @try
    {
        return [self substringWithRange:aRange];
    }
    @catch (NSException *exception)
    {
//        ASSERT(false);//取的长度大于字符串本身的长度了。这里有问题啊，暴露下-------cutideliu
        return @"";
    }
     */
    
    // 此处的判断中，NSUInteger需要转换成NSInteger使用，否则会溢出。by crisszhang 2016年02月18日
    if ((aRange.location != NSNotFound) && (((NSInteger)aRange.location - 1) < (NSInteger)self.length) && ((NSInteger)aRange.location + (NSInteger)aRange.length - 1) < (NSInteger)self.length) {
        return [self substringWithRange:aRange];
    }
    else
    {
        return @"";
    }
    
}

- (NSString *)safe_SubstringFromIndex:(NSUInteger)index
{
    /*
    @try {
        return [self substringFromIndex:index];
    }
    @catch (NSException *exception) {
        return @"";
    }
     */
    if (index < (self.length + 1)) {
        return [self substringFromIndex:index];
    }
    else
    {
        return @"";
    }
}

- (NSString *)safe_SubstringToIndex:(NSUInteger)index
{
    /*
    @try {
        return [self substringToIndex:index];
    }
    @catch (NSException *exception) {
        return @"";
    }
     */
    
    if (index < (self.length + 1)) {
        return [self substringToIndex:index];
    }
    else
    {
        return @"";
    }
    
}

- (BOOL)isNumberString
{
    if (self.length < 1) {
        return NO;
    }
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return ([scan scanInt:&val] && [scan isAtEnd]);
}

- (BOOL)isInsensitiveSubstringOfString:(NSString *)string
{
    if (self.length < 1 || !string || string.length < 1 || self.length > string.length) {
        return NO;
    }
    //NSUInteger nextSearchLocation = 0;
    NSRange range;
    NSRange searchRange;
    searchRange.location = 0;
    searchRange.length = string.length;
    range.length = 1;
    for (NSInteger i = 0; i < self.length; i++) {
        range.location = i;
        NSUInteger nextSearchLocation = [string rangeOfString:[self substringWithRange:range] options:NSCaseInsensitiveSearch range:searchRange].location;
        if (nextSearchLocation != NSNotFound) {
            searchRange.location = nextSearchLocation + 1;
            searchRange.length = string.length - searchRange.location;
            if (searchRange.location >= string.length && i < (self.length - 1)) {
                return NO;
            }
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
//    NSCharacterSet *invertedSet=[characterSet invertedSet];
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}



+ (NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;?"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

+ (NSString *)generateUuidString{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

- (BOOL)isEmpty
{
    return [[self trimWhitespace] isEqualToString:@""];
}

/* 每个emoji当成是一个字符
- (NSUInteger)charactersCount
{
    NSInteger count = 0;
    NSString *originStr = self;
    NSRange range;
    NSString *lastRangeStr = nil;
    
    for (NSInteger i = 0; i < originStr.length; i += range.length) {
        range = [originStr rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *nowRangeStr = [originStr substringWithRange:range];
        if (!lastRangeStr) {
            lastRangeStr = nowRangeStr;
        }
        else{
            NSString *testStr = [NSString stringWithFormat:@"%@%@",lastRangeStr,nowRangeStr];
            lastRangeStr = nowRangeStr;
            //若前一次和当前拼起来的str在黑名单中，则跳过计数加1
            if ([self stringIsInBlackList:testStr]) {
                continue;
            }
        }
        count ++;
    }
    return count;
}
*/

// emoji占用多少个字符就当成是多少字符，这里可以对字符规则做更多扩展
- (NSUInteger)charactersCount
{
    return [self length];
}

- (NSString*)substringWithinMaxCount:(NSUInteger) maxCount
{
    NSInteger count = 0;
    NSString *originStr = [self copy];
    NSRange range;
    NSString *subStr = originStr;
    NSString *lastRangeStr = nil;
    
    for (NSInteger i = 0; i < originStr.length; i += range.length) {
        range = [originStr rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *nowRangeStr = [originStr substringWithRange:range];
        if (!lastRangeStr) {
            lastRangeStr = nowRangeStr;
        }
        else{
            NSString *testStr = [NSString stringWithFormat:@"%@%@",lastRangeStr,nowRangeStr];
            lastRangeStr = nowRangeStr;
            //若前一次和当前拼起来的str在黑名单中，则跳过计数加1
            if ([self stringIsInBlackList:testStr]) {
                continue;
            }
        }
        
        count ++;
        
        if (count == maxCount) {
            //当计数达到上限时，还需要判断下当前的str和后面的是否在黑名单中
            NSInteger tmp = i +range.length;
            if (tmp < originStr.length) {
                NSRange tmpRange = [originStr rangeOfComposedCharacterSequenceAtIndex:tmp];
                NSString *tmpRangeStr = [originStr substringWithRange:tmpRange];
                
                NSString *testStr = [NSString stringWithFormat:@"%@%@",lastRangeStr,tmpRangeStr];
                if ([self stringIsInBlackList:testStr]) {
                    subStr = [originStr substringToIndex:tmpRange.location + tmpRange.length];
                }
                else{
                    subStr = [originStr substringToIndex:range.location + range.length];
                }
            }
            else{
                subStr = [originStr substringToIndex:range.location + range.length];
            }
            break;
        }
    }
    return subStr;
}


- (BOOL)stringIsInBlackList:(NSString*)string
{
    NSArray *blackListArray = [NSArray arrayWithObjects:@"��",@"��",@"��",@"��",@"��",@"��",@"��",@"��",@"��",@"��", nil];
    for (NSString *str in blackListArray) {
        if ([string isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)urlStringByAppendingParameter:(NSString *)parameter
{
    NSString *url = self;
    if (parameter == nil)
    {
        return self;
    }
    NSRange rangeOfString = [url rangeOfString:parameter];
    if (rangeOfString.location == NSNotFound)
    {
        if ([url rangeOfString:@"?"].location == NSNotFound)
        {
            url = [url stringByAppendingFormat:@"?%@", parameter];
        }
        else
        {
            url = [url stringByAppendingFormat:@"&%@", parameter];
        }
        
    }
    return url;
}

@end
