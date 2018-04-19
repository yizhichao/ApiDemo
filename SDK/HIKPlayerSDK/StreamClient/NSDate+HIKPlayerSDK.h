//
//  NSDate+Ex.h
//  iVMS4500
//
//  Created by wuyang on 12-7-8.
//  Copyright (c) 2012年 Hangzhou Hikvision Digital Tech. Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HIKPlayerSDK)

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day 
                    hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

+ (NSDate *)dateWithCalendar:(NSCalendar *)calendar
                        year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
                        hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

- (void)getYear:(NSInteger *)year
          month:(NSInteger *)month
            day:(NSInteger *)day
           hour:(NSInteger *)hour
         minute:(NSInteger *)minute
         second:(NSInteger *)second;

- (void)getYear:(NSInteger *)year
          month:(NSInteger *)month
            day:(NSInteger *)day
           hour:(NSInteger *)hour
         minute:(NSInteger *)minute
         second:(NSInteger *)second
   withCalendar:(NSCalendar *)calendar;

- (void)getYear:(NSInteger *)year month:(NSInteger *)month day:(NSInteger *)day;

- (void)getYear:(NSInteger *)year
          month:(NSInteger *)month
            day:(NSInteger *)day
   withCalendar:(NSCalendar *)calendar;

// 获取格式化的字符串，如 @"yyyy-MM-dd HH:mm:ss"
- (NSString *)stringWithFormat:(NSString *)format;

@end
