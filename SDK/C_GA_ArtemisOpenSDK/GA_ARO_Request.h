//
//  GA_ARO_Request.h
//  GA_ARO_SDK
//
//  Created by wangyong14 on 2017/11/20.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger,GA_ARO_REQUEST_METHOD){
    GA_ARO_REQUEST_METHOD_GET,
    GA_ARO_REQUEST_METHOD_GETPOST_FORM,
    GA_ARO_REQUEST_METHOD_GETPOST_STRING,
    GA_ARO_REQUEST_METHOD_GETPOST_BYTES,
    GA_ARO_REQUEST_METHOD_GETPUT_FORM,
    GA_ARO_REQUEST_METHOD_GETPUT_STRING,
    GA_ARO_REQUEST_METHOD_PUT_BYTES,
    GA_ARO_REQUEST_METHOD_GETDELETE
};


@interface GA_ARO_Request : NSObject

/**
 * （必选）请求方法
 */
@property(nonatomic,assign)GA_ARO_REQUEST_METHOD method;

/**
 * （必选）Host
 */
@property(nonatomic,copy) NSString *host;


/**
 * （必选）Path
 */
@property(nonatomic,copy) NSString *path;

/**
 * （必选)APP KEY
 */
@property(nonatomic,copy) NSString *appKey;


/**
 * （必选）APP密钥
 */
@property(nonatomic,copy) NSString *appSecret;

/**
 * （必选）超时时间,单位毫秒,设置零默认使用com.aliyun.apigateway.demo.constant.Constants.DEFAULT_TIMEOUT
 */
@property(nonatomic,assign)NSInteger timeout;


/**
 * （可选） HTTP头
 */
@property(nonatomic,strong) NSMutableDictionary<NSString *,NSString *> *headers;

/**
 * （可选） Querys
 */
@property(nonatomic,strong) NSMutableDictionary<NSString *,NSString *> *querys;

/**
 * （可选）字符串Body体
 */
@property(nonatomic,copy) NSString *stringBody;



-(void)check;

@end
