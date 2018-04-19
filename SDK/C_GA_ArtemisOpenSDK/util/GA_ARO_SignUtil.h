//
//  C_GA_ArtemisSignUtil.h
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/20.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NSString+C_GA_ArtemisEncry.h"

@interface GA_ARO_SignUtil : NSObject


+(NSString *)signWithSecret:(NSString *) secret
                     method:(NSString *) method
                       path:(NSString *) path
                    headers:(NSMutableDictionary *) headers
                     querys:(NSMutableDictionary *) querys
                      bodys:(NSMutableDictionary *) bodys
       signHeaderPrefixList:(NSMutableArray<NSString *> *) signHeaderPrefixList;






@end
