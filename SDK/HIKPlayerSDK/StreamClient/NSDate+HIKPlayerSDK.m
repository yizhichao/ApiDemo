//
//  NSDate+Ex.m
//  iVMS4500
//
//  Created by wuyang on 12-7-8.
//  Copyright (c) 2012年 Hangzhou Hikvision Digital Tech. Co.,Ltd. All rights reserved.
//

#import "NSDate+HIKPlayerSDK.h"

@implementation NSDate (HIKPlayerSDK)

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
                    hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate dateWithCalendar:calendar year:year month:month
                                        day:day hour:hour minute:minute
                                     second:second];
    return date;
}

+ (NSDate *)dateWithCalendar:(NSCalendar *)calendar year:(NSInteger)year month:(NSInteger)month
                         day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
                      second:(NSInteger)second
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    dateComponents.hour = hour;
    dateComponents.minute = minute;
    dateComponents.second = second;
    
    NSDate *date = [calendar dateFromComponents:dateComponents];
    return date;
}

- (void)getYear:(NSInteger *)year month:(NSInteger *)month day:(NSInteger *)day
           hour:(NSInteger *)hour minute:(NSInteger *)minute second:(NSInteger *)second
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [self getYear:year month:month day:day hour:hour minute:minute second:second withCalendar:calendar];
}

- (void)getYear:(NSInteger *)year month:(NSInteger *)month day:(NSInteger *)day
           hour:(NSInteger *)hour minute:(NSInteger *)minute second:(NSInteger *)second
   withCalendar:(NSCalendar *)calendar
{
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    *year = dateComponents.year;
    *month = dateComponents.month;
    *day = dateComponents.day;
    *hour = dateComponents.hour;
    *minute = dateComponents.minute;
    *second = dateComponents.second;
}

- (void)getYear:(NSInteger *)year month:(NSInteger *)month day:(NSInteger *)day
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [self getYear:year month:month day:day withCalendar:calendar];
}

- (void)getYear:(NSInteger *)year month:(NSInteger *)month day:(NSInteger *)day
   withCalendar:(NSCalendar *)calendar
{
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    *year = dateComponents.year;
    *month = dateComponents.month;
    *day = dateComponents.day;
}

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    dateFormatter.dateFormat = format;
    NSString *dateString = [dateFormatter stringFromDate:self];

    return dateString;
}

@end
