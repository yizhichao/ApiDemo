//
//  ApiConfig.m
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import "ApiConfig.h"

@implementation ApiConfig

+ (instancetype)shareConfig {
    static dispatch_once_t onceToken;
    static ApiConfig *config = nil;
    dispatch_once(&onceToken, ^{
        config = [[ApiConfig alloc] init];
    });
    return config;
}

@end
