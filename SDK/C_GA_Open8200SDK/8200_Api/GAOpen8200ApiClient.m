//
//  Open8200ApiClient.m
//  Pods
//
//  Created by wangyong14 on 2017/11/20.
//

#import "GAOpen8200ApiClient.h"
#import "C_GA_ArtemisOpenSDK.h"


@implementation GAOpen8200ApiClient

+ (instancetype)sharedInstance
{
    static GAOpen8200ApiClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GAOpen8200ApiClient alloc] init];
    });
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DXLOGIN_SUCCESS"
                                                      object:nil
                                                       queue:[NSOperationQueue new]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      NSDictionary *dic = note.object;
                                                      _sharedInstance.artemisAppKey = [dic valueForKey:@"appKey"];
                                                      _sharedInstance.artemisAppSecret = [dic valueForKey:@"appSecret"];
                                                      _sharedInstance.apiGatewayUrl = [dic valueForKey:@"host"];
                                                      
                                                  }];
    
    return _sharedInstance;
}

+(void)getAppSecretCompletion:(void(^)(NSString *appSecret,NSError *error))completion {
    
    GA_ARO_Request *request = [GA_ARO_Request new];
    
    GAOpen8200ApiClient *client =[GAOpen8200ApiClient sharedInstance];
    if (!client.apiGatewayUrl || !client.artemisAppKey) {
        NSError *error = [NSError errorWithDomain:@"GAOpen8200ApiClient" code:500 userInfo:@{NSLocalizedDescriptionKey:@"api网关信息缺失"}];
        completion(nil,error);
        return;
    }
    if (client.artemisAppSecret && ![client.artemisAppSecret isEqualToString:@""]) {
        request;
    }
    request.host = client.apiGatewayUrl;
    request.path = @"/artemis/api/vms/v1/videoParamPath";
    request.appKey =client.artemisAppKey;
    request.appSecret =client.artemisAppSecret;
    request.querys = @{@"appKey":client.artemisAppKey};

    [GA_ARO_Client get:request completion:^(GA_ARO_Response *response, NSError *error) {
        if (error) {
            completion(nil,error);
            return;
        }
        if (response.statusCode !=200) {
            NSString *errorMsg = response.errorMessage?response.errorMessage:@"";
            NSError *errorTemp =  [NSError errorWithDomain:@"GAOpen8200ApiClient" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            completion(nil,errorTemp);
        }
        
        if (response.statusCode==200) {
            
            NSData *jsonData = [response.body dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSString *appSecret = dic[@"data"];
            client.artemisAppSecret = appSecret;
            completion(appSecret,error);
        }
    }];
}

+(void)getRealPlayRtspURL:(NSString *)indexCode completion:(void (^)(NSString *, NSError *))completion{
    
    GA_ARO_Request *request = [GA_ARO_Request new];
    
    GAOpen8200ApiClient *client =[GAOpen8200ApiClient sharedInstance];
    if (!client.apiGatewayUrl||!client.artemisAppKey||!client.artemisAppSecret) {
        NSError *error = [NSError errorWithDomain:@"GAOpen8200ApiClient" code:500 userInfo:@{NSLocalizedDescriptionKey:@"api网关信息缺失"}];
        completion(nil,error);
        return;
    }
    
    request.host = client.apiGatewayUrl;
    request.path = [@"/artemis/api/vms/v1/rtsp/basic/" stringByAppendingString:indexCode];
    request.appKey =client.artemisAppKey;
    request.appSecret =client.artemisAppSecret;
    
//    request.host = @"https://open8200.hikvision.com";
//    request.appKey =@"22296013";
//    request.appSecret =@"Gpylwje4gRdyM9vMDpiK";
//    request.querys = @{@"indexCode":@"14000000001310014931"};

//    request.path = [NSString stringWithFormat:@"%@%@",@"/artemis/api/vms/v1/rtsp/basic/",@"14000000001310014931"];

    
    [GA_ARO_Client get:request completion:^(GA_ARO_Response *response, NSError *error) {
        if (error) {
            completion(nil,error);
            return;
        }
        if (response.statusCode !=200) {
            NSString *errorMsg = response.errorMessage?response.errorMessage:@"";
            NSError *errorTemp =  [NSError errorWithDomain:@"GAOpen8200ApiClient" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            completion(nil,errorTemp);
        }
        
        if (response.statusCode==200) {
            
            NSData *jsonData = [response.body dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSString *rtspUrl  =dic[@"data"];
            completion(rtspUrl,error);
        }
     
        
    }];
}

+(void)getCameraListStart:(NSInteger)start
                     size:(NSInteger)size
                  orderby:(NSString *)desc
                    order:(NSString *)order
                 complete:(void (^)(NSArray *cameraArray, NSError *error))completion {
    
    GA_ARO_Request *request = [GA_ARO_Request new];
    GAOpen8200ApiClient *client = [GAOpen8200ApiClient sharedInstance];
    if (!client.apiGatewayUrl||!client.artemisAppKey||!client.artemisAppSecret) {
        NSError *error = [NSError errorWithDomain:@"GAOpen8200ApiClient" code:500 userInfo:@{NSLocalizedDescriptionKey:@"api网关信息缺失"}];
        completion(nil,error);
        return;
    }
    
    request.host = client.apiGatewayUrl;
    request.path = @"/artemis/api/common/v1/remoteCameraInfoRestService/findCameraInfoPage";
    request.appKey =client.artemisAppKey;
    request.appSecret =client.artemisAppSecret;
    [GA_ARO_Client get:request completion:^(GA_ARO_Response *response, NSError *error) {
        if (error) {
            completion(nil,error);
            return;
        }
        if (response.statusCode !=200) {
            NSString *errorMsg = response.errorMessage?response.errorMessage:@"";
            NSError *errorTemp =  [NSError errorWithDomain:@"GAOpen8200ApiClient" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            completion(nil,errorTemp);
        }
        
        if (response.statusCode==200) {
            
            NSData *jsonData = [response.body dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSArray *cameraArray = dic[@"data"];
            completion(cameraArray,error);
        }
    }];
}

+(void)recordQueryService:(NSString *)indexCode
                beginTime:(NSDate *)beginTime
                  endTime:(NSDate *)endTime
                recordPos:(NSString *)recordPos
               completion:(void (^)(NSArray *recordArray,NSString *totalTimeUrl,NSError *error))completion{
    
    GAOpen8200ApiClient *client =[GAOpen8200ApiClient sharedInstance];
    
    if (!client.apiGatewayUrl||!client.artemisAppKey||!client.artemisAppSecret) {
        NSError *error = [NSError errorWithDomain:@"GAOpen8200ApiClient" code:500 userInfo:@{NSLocalizedDescriptionKey:@"api网关信息缺失"}];
        completion(nil,nil,error);
        return;
    }
    
    GA_ARO_Request *request = [GA_ARO_Request new];
    request.host = client.apiGatewayUrl;
    request.path = @"/artemis/api/RecordQueryService/v1/queryServer";
    request.appKey =client.artemisAppKey;
    request.appSecret =client.artemisAppSecret;
    NSNumber *tempbeginTime = [NSNumber numberWithDouble:[beginTime timeIntervalSince1970]];
    NSNumber *tempEndTime = [NSNumber numberWithDouble:[endTime timeIntervalSince1970]];
    request.querys = @{@"cameraId":indexCode,
                       @"queryType":@"23",
                       @"recordPos":recordPos,
                       @"beginTime":[tempbeginTime stringValue],
                       @"endTime":[tempEndTime stringValue]};
    
    [GA_ARO_Client get:request completion:^(GA_ARO_Response *response, NSError *error) {
        if (error) {
            completion(nil,nil,error);
            return;
        }
        if (response.statusCode !=200) {
            NSString *errorMsg = response.errorMessage?response.errorMessage:@"";
            NSError *errorTemp =  [NSError errorWithDomain:@"GAOpen8200ApiClient" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            completion(nil,nil,errorTemp);
        }
        
        if (response.statusCode==200) {
            
            NSData *jsonData = [response.body dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSDictionary *dataDic =dic[@"data"];
            NSArray *recordArray  =dataDic[@"list"];
            NSString *totalTimeUrl = dataDic[@"totalTimeUrl"];
            completion(recordArray,totalTimeUrl,error);
        }
    }];
}

+ (void)controlPTZ:(NSString *)indexCode
           command:(NSString *)direction
             speed:(NSInteger)speed
            action:(NSInteger)action
         comletion:(void (^)(id json, NSError *))completion {
    
    GAOpen8200ApiClient *client =[GAOpen8200ApiClient sharedInstance];
    
    if (!client.apiGatewayUrl||!client.artemisAppKey||!client.artemisAppSecret) {
        NSError *error = [NSError errorWithDomain:@"GAOpen8200ApiClient" code:500 userInfo:@{NSLocalizedDescriptionKey:@"api网关信息缺失"}];
        completion(nil, error);
        return;
    }
    
    GA_ARO_Request *request = [GA_ARO_Request new];
    request.host = client.apiGatewayUrl;
    request.path = @"/artemis/api/RecordQueryService/v1/queryServer";
    request.appKey =client.artemisAppKey;
    request.appSecret =client.artemisAppSecret;
    request.querys = @{@"cameraId":indexCode,
                       @"queryType":@"23",
                       @"command":direction,
                       @"action":[@(action) stringValue],
                       @"speed":[@(speed) stringValue]};
    
    [GA_ARO_Client get:request completion:^(GA_ARO_Response *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        if (response.statusCode !=200) {
            NSString *errorMsg = response.errorMessage?response.errorMessage:@"";
            NSError *errorTemp =  [NSError errorWithDomain:@"GAOpen8200ApiClient" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            completion(nil, errorTemp);
        }
        
        if (response.statusCode==200) {
            
            NSData *jsonData = [response.body dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSDictionary *dataDic =dic[@"data"];
            completion(dataDic,nil);
        }
    }];
}




-(NSString *)apiGatewayUrl{
    if ([_apiGatewayUrl hasSuffix:@"/"]){
        NSInteger index =[self lastIndexOfStr:@"/"];
        if (index==-1) {
            return  _apiGatewayUrl;
        }
        return  [_apiGatewayUrl substringToIndex:index];
    }
    return _apiGatewayUrl;
}


-(NSInteger)lastIndexOfStr:(NSString *)str{
    NSUInteger length = [_apiGatewayUrl length];
    NSRange range = [_apiGatewayUrl rangeOfString:str];
    NSInteger index=-1;
    if (range.location<length) {
        index = range.location;
    }
    while (range.location<length) {
        range = [_apiGatewayUrl rangeOfString:str options:NSCaseInsensitiveSearch range:NSMakeRange(range.location+range.length,length-range.location-range.length)];
        if (range.location<length) {
            index = range.location;
        }
    }
    return index;
}




@end
