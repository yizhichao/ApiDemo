//
//  GA_ARO_HttpUtil.h
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/21.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GA_ARO_HttpUtil : NSObject


/**
 get请求
 注意Content-type不要随意设置，会导致请求失败，没有设置，我们会默认设置
 @param host 服务IP
 @param path 请求路径
 @param timeOut 超时时间
 @param headers 请求头
 @param querys 查询条件
 @param appKey appkey
 @param appSecret 密匙
 */
+(void) httpGet:(NSString *)host
           path:(NSString *)path
        timeOut:(NSInteger)timeOut
        headers:(NSMutableDictionary *)headers
         querys:(NSMutableDictionary *)querys
         appkey:(NSString *) appKey
      appSecret:(NSString *) appSecret
     completion:(void (^)(NSHTTPURLResponse *response,id  _Nullable responseObject,NSError *error))completion;


+(void) httpPost:(NSString *)host
            path:(NSString *)path
         timeOut:(NSInteger)timeOut
         headers:(NSMutableDictionary *)headers
            body:(NSString *)body
          appkey:(NSString *) appKey
       appSecret:(NSString *) appSecret
      completion:(void (^)(NSHTTPURLResponse *response,id  _Nullable responseObject,NSError *error))completion;


+(void) httpPost:(NSString *)host
            path:(NSString *)path
         timeOut:(NSInteger)timeOut
         headers:(NSMutableDictionary *)headers
          querys:(NSMutableDictionary *)querys
          appkey:(NSString *) appKey
       appSecret:(NSString *) appSecret
      completion:(void (^)(NSHTTPURLResponse *response,id  _Nullable responseObject,NSError *error))completion;





@end
