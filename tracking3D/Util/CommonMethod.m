//
//  CommonMethod.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 12/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "CommonMethod.h"
#import "NSString+Extern.h"
@implementation CommonMethod

+ (UIColor*) colorWithHexString:(NSString *)hexString
{
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString safe_SubstringWithRange:NSMakeRange(0, 1)],[cleanString safe_SubstringWithRange:NSMakeRange(0, 1)],
                       [cleanString safe_SubstringWithRange:NSMakeRange(1, 1)],[cleanString safe_SubstringWithRange:NSMakeRange(1, 1)],
                       [cleanString safe_SubstringWithRange:NSMakeRange(2, 1)],[cleanString safe_SubstringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
