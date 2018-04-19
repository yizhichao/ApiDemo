//
//  ApiConfig.h
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiConfig : NSObject

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) NSString *host;

@property (nonatomic, copy) NSString *appSecret;

+ (instancetype)shareConfig;

@end
