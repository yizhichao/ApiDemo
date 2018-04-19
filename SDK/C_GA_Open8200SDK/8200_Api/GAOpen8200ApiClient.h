//
//  Open8200ApiClient.h
//  Pods
//
//  Created by wangyong14 on 2017/11/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SubStreamType) {
    SubStreamTypeMain = 0,
    SubStreamTypeSub = 1
};

@interface GAOpen8200ApiClient : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *apiGatewayUrl;

@property (nonatomic, copy) NSString *artemisAppKey;

@property (nonatomic, copy) NSString *artemisAppSecret;

+(void)getRealPlayRtspURL:(NSString *)indexCode
               completion:(void (^)(NSString *rtspUrl,NSError *error))completion;

+(void)getAppSecretCompletion:(void(^)(NSString *appSecret,NSError *error))completion;

/**
 查询摄像头列表
 
 @param start 第几页开始，起始值0
 @param size 每页大小
 @param desc 排序字段，多个字段以,分隔
 @param order 排序方式(升序:asc,降序:desc),配合orderby字段使用,默认升序。如有多个排序字段使用,分隔
 */
+(void)getCameraListStart:(NSInteger)start
                     size:(NSInteger)size
                  orderby:(NSString *)desc
                    order:(NSString *)order
                 complete:(void (^)(NSArray *cameraArray, NSError *error))completion;

/**
 查询历史录像

 @param indexCode 摄像头的IndexCode
 @param beginTime 录像查询的开始时间
 @param endTime 录像查询的结束时间
 @param recordPos 1 设备存储 2中心存储
 */
+(void)recordQueryService:(NSString *)indexCode
                beginTime:(NSDate *)beginTime
                  endTime:(NSDate *)endTime
                recordPos:(NSString *)recordPos
               completion:(void (^)(NSArray *recordArray,NSString *totalTimeUrl, NSError *error))completion;

/**
 开始云台控制
 
 @param indexCode 摄像头的IndexCode
 @param command  "LEFT", "RIGHT", "UP", "DOWN", "LEFT_UP", "LEFT_DOWN", "RIGHT_UP", "RIGHT_DOWN", "ZOOMIN", "ZOOMOUT"
 @param action  0 停止 1 启动
 @param speed    旋转速度
 */
+ (void)controlPTZ:(NSString *)indexCode
           command:(NSString *)direction
             speed:(NSInteger)speed
            action:(NSInteger)action
         comletion:(void (^)(id json, NSError *error))completion;

@end
