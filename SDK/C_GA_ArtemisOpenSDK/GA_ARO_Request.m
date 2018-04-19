//
//  C_GA_ArtemisRequest.m
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/20.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import "GA_ARO_Request.h"

@implementation GA_ARO_Request


-(void)check{
    NSAssert(self.host, @"GA_ARO_Request.host can not be nil or ''");
    NSAssert(self.appKey, @"GA_ARO_Request.appKey can not be nil or ''");
    NSAssert(self.appSecret, @"GA_ARO_Request.appSecret can not be nil or ''");
    if (self.headers) {
        NSAssert([self.headers isKindOfClass:[NSMutableDictionary class]], @"GA_ARO_Request.headers must be NSMutableDictionary");
    }
}

@end
