//
//  NumberToFiles.h
//  AVAudioPlayerQueue
//
//  Created by CIA on 14/06/2018.
//  Copyright © 2018 CIA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    //英文文件
    KFileTypeEnglish,
    //中文文件
    KFileTypeCN
} FileType;

@interface NumberToFiles : NSObject

//整数转换
+(NSArray <NSString *>*)fileNamesWithIntValue:(int)intValue fileType:(FileType)type;

//小数转换,只能保留一位小数
+(NSArray <NSString *>*)fileNamesWithFloatValue:(double)floatValue fileType:(FileType)type;


@end
