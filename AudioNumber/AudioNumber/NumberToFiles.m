//
//  NumberToFiles.m
//  AVAudioPlayerQueue
//
//  Created by CIA on 14/06/2018.
//  Copyright © 2018 CIA. All rights reserved.
//

#import "NumberToFiles.h"

@implementation NumberToFiles


//整数转换
+(NSArray <NSString *>*)fileNamesWithIntValue:(int)intValue fileType:(FileType)type{
    if (type == KFileTypeCN) {
        //中文
        int bigValue = intValue / 10000;
        int remain = intValue - bigValue * 10000;
        NSMutableArray *array = [NSMutableArray new];
        if (bigValue > 0) {
            //处理万位
            [array addObjectsFromArray:[self CNValueLess10000:bigValue initialHasZero:NO hasUpper:NO]];
            [array addObject:@"CN_wan.mp3"];
        }
        //检查要加0
        BOOL hasUpper = array.count > 0;
        if (bigValue > 0 && remain / 1000 == 0) {
            [array addObject:@"CN0.mp3"];
            [array addObjectsFromArray:[self CNValueLess10000:remain initialHasZero:YES hasUpper:hasUpper]];
        } else {
            [array addObjectsFromArray:[self CNValueLess10000:remain initialHasZero:NO  hasUpper:hasUpper]];
        }
        if (array.count == 0) {
            [array addObject:@"CN0.mp3"];
        }
        return array;
    } else {
        //英文
        int bigValue = intValue / 1000;
        int remain = intValue - bigValue * 1000;
        NSMutableArray *array = [NSMutableArray new];
        if (bigValue > 0) {
            //处理千位
            [array addObjectsFromArray:[self EnValueLess1000:bigValue]];
            [array addObject:@"EN1000.m4a"];
        }
        if (remain > 0) {
            [array addObjectsFromArray:[self EnValueLess1000:remain]];
        }
        if (array.count == 0) {
            [array addObject:@"EN0.m4a"];
        }
        return array;
    }
}

//小数转换,只能保留一位小数
+(NSArray <NSString *>*)fileNamesWithFloatValue:(double)floatValue fileType:(FileType)type{
    NSMutableArray *items = [NSMutableArray new];
    int intValue = (int)floatValue;
    double remain = floatValue - intValue;
    [items addObjectsFromArray:[self fileNamesWithIntValue:intValue fileType:type]];
    //小数部分最多读取4位小数
    int smallValue = (int)(remain * 10000 + 0.4);
    if (smallValue > 0) {
        NSMutableArray *tempArray = [NSMutableArray new];
        BOOL isFindNoneZero = NO;
        int i = 4; //确保会执行4次循环
        while (i > 0) {
            int value = smallValue % 10;
            if (value > 0) {
                if (type == KFileTypeCN) {
                    [tempArray addObject:[NSString stringWithFormat:@"CN%d.mp3",value]];
                } else {
                    [tempArray addObject:[NSString stringWithFormat:@"EN%d.m4a",value]];
                }
                isFindNoneZero = YES;
            } else {
                if (isFindNoneZero) {
                    if (type == KFileTypeCN) {
                        [tempArray addObject:@"CN0.mp3"];
                    } else {
                        [tempArray addObject:@"EN0.m4a"];
                    }
                }
            }
            smallValue /= 10;
            i -= 1;
        }
        if (type == KFileTypeCN) {
            [items addObject:@"CNpoint.mp3"];
        } else {
            [items addObject:@"ENpoint.m4a"];
        }
        [items addObjectsFromArray:tempArray.reverseObjectEnumerator.allObjects];
    }
    return items;
}

#pragma mark - 中文转换
//小于1万的数字的中文转换
+(NSArray <NSString *>*)CNValueLess10000:(int)value initialHasZero:(BOOL)initialHasZero hasUpper:(BOOL) hasUpper{
    int thousand = value / 1000;
    value = value - thousand * 1000;
    int hundred = value / 100;
    value = value - hundred * 100;
    int ten = value / 10;
    int digital = value % 10;
    
    NSMutableArray *items = [NSMutableArray new];
    BOOL hasZero = initialHasZero;
    if (thousand > 0) {
        [items addObject:[NSString stringWithFormat:@"CN%d.mp3",thousand]];
        [items addObject:@"CNthousand.mp3"];
    }
    if (hundred > 0) {
        [items addObject:[NSString stringWithFormat:@"CN%d.mp3",hundred]];
        [items addObject:@"CNhundred.mp3"];
        hasZero = NO;
    } else {
        if (thousand > 0 && hasZero == NO) {
            [items addObject:@"CN0.mp3"];
            hasZero = YES;
        }
    }
    
    if (ten > 0) {
        if (ten > 1) {
            [items addObject:[NSString stringWithFormat:@"CN%d.mp3",ten]];
            [items addObject:@"CN10.mp3"];
        } else {
            if (hasUpper || items.count > 0) {
                //需要读一十八
                [items addObject:@"CN1.mp3"];
                [items addObject:@"CN10.mp3"];
            } else {
                //读18
                [items addObject:@"CN10.mp3"];
            }
        }
        hasZero = NO;
    } else {
        if ((thousand > 0 || hundred > 0) && hasZero == NO) {
            [items addObject:@"CN0.mp3"];
            hasZero = YES;
        }
    }
    if (digital > 0) {
        [items addObject:[NSString stringWithFormat:@"CN%d.mp3",digital]];
    }
    return items;
}

#pragma mark - 英文转换
//小于1000的数字的文转换
+(NSArray <NSString *>*)EnValueLess1000:(int)value{
    int hundred = value / 100;
    value = value - hundred * 100;
    
    NSMutableArray *items = [NSMutableArray new];
    if (hundred > 0) {
        [items addObject:[NSString stringWithFormat:@"EN%d.m4a",hundred]];
        [items addObject:@"EN100.m4a"];
        if (value > 0) {
            [items addObject:@"and.mp3"];
        }
    }
    if (value != 0) {
        if (value <= 20) {
            [items addObject:[NSString stringWithFormat:@"EN%d.m4a",value]];
        } else {
            [items addObject:[NSString stringWithFormat:@"EN%d.m4a",value/10 * 10]];
            if (value % 10 != 0) {
                [items addObject:[NSString stringWithFormat:@"EN%d.m4a",value%10]];
            }
        }
    }
    return items;
}
@end
