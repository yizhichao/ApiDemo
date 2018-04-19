//
//  GA_ARO_HttpUtil.m
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/21.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import "GA_ARO_HttpUtil.h"
#import "GA_ARO_Constants.h"
#import "GA_ARO_ContentType.h"
#import "GA_ARO_HttpHeader.h"
#import "GA_ARO_HttpMethod.h"
#import "GA_ARO_HttpSchema.h"
#import "GA_ARO_SystemHeader.h"
#import "GA_ARO_SignUtil.h"
#import "GA_ARO_HTTPSessionManager.h"


@implementation GA_ARO_HttpUtil



+(void) httpGet:(NSString *)host
           path:(NSString *)path
        timeOut:(NSInteger)timeOut
        headers:(NSMutableDictionary *)headers
         querys:(NSMutableDictionary *)querys
         appkey:(NSString *) appKey
      appSecret:(NSString *) appSecret
     completion:(void (^)(NSURLSessionDataTask * _Nonnull task,id  _Nullable responseObject,NSError *error))completion{
    
    headers =  [self initialBasicHeader:GET
                                   path:path
                                headers:headers
                                 querys:querys
                                  bodys:nil
                   signHeaderPrefixList:nil
                                 appKey:appKey
                              appSecret:appSecret];
    
    GA_ARO_HTTPSessionManager *httpManager = [self httpManager:headers timeOut:timeOut];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",host,path];
    
    [httpManager GET:url parameters:querys progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSURLResponse *response =   task.response;
        
        if (completion) {
            completion(response,responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        error = [self hanlderErrorMsg:error];
        if (completion) {
            completion(task.response,nil,error);
        }
    }];
    
}


+(void) httpPost:(NSString *)host
            path:(NSString *)path
         timeOut:(NSInteger)timeOut
         headers:(NSMutableDictionary *)headers
            body:(NSString *)body
          appkey:(NSString *) appKey
       appSecret:(NSString *) appSecret
      completion:(void (^)(NSHTTPURLResponse * _Nonnull response,id  _Nullable responseObject,NSError *error))completion{
    if (!headers) {
        headers = [NSMutableDictionary new];
    }
    headers[HTTP_HEADER_CONTENT_TYPE] = CONTENT_TYPE_JSON;

    headers = [self initialBasicHeader:POST
                                  path:path
                               headers:headers
                                querys:nil
                                 bodys:nil
                  signHeaderPrefixList:nil
                                appKey:appKey
                             appSecret:appSecret];
    
    GA_ARO_HTTPSessionManager *httpManager = [self httpManager:headers timeOut:timeOut];
    NSString *url = [NSString stringWithFormat:@"%@%@",host,path];
    
    NSMutableURLRequest *request = [[GA_ARO_JSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                       URLString:url
                                                                                      parameters:nil
                                                                                           error:nil];
    
    
  
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];

    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[httpManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = response;
        error = [self hanlderErrorMsg:error];
        if (completion) {
            completion(httpResponse,responseObject,error);
        }
    }] resume];
}

+(void)httpPost:(NSString *)host
           path:(NSString *)path
        timeOut:(NSInteger)timeOut
        headers:(NSMutableDictionary *)headers
         querys:(NSMutableDictionary *)querys
         appkey:(NSString *)appKey
      appSecret:(NSString *)appSecret
     completion:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable, NSError *))completion{
    if (!headers) {
        headers = [NSMutableDictionary new];
    }
    headers[HTTP_HEADER_CONTENT_TYPE] = CONTENT_TYPE_JSON;
    headers = [self initialBasicHeader:POST
                                  path:path
                               headers:headers
                                querys:querys
                                 bodys:nil
                  signHeaderPrefixList:nil
                                appKey:appKey
                             appSecret:appSecret];
    
    GA_ARO_HTTPSessionManager *httpManager = [self httpManager:headers timeOut:timeOut];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",host,path];
    
    [httpManager POST:url parameters:querys progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSURLResponse *response = task.response;
        if (completion) {
            completion(response,responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        error = [self hanlderErrorMsg:error];
        if (completion) {
            completion(task.response,nil,error);
        }
    }];    
}







+(NSMutableDictionary *)initialBasicHeader:(NSString *)method
                                      path:(NSString *)path
                                   headers:(NSMutableDictionary<NSString *,NSString *> *)headers
                                    querys:(NSMutableDictionary<NSString *,NSString *> *)querys
                                     bodys:(NSMutableDictionary<NSString *,NSString *> *)bodys
                      signHeaderPrefixList:(NSMutableArray<NSString *> *)signHeaderPrefixList
                                    appKey:(NSString *)appKey
                                 appSecret:(NSString *)appSecret{
    if (!headers) {
        headers = [NSMutableDictionary new];
    }
    NSTimeInterval time =[[NSDate new] timeIntervalSince1970];
    time = time*1000;
    NSNumber *num = [NSNumber numberWithDouble:time];
    
    if (!headers[HTTP_HEADER_CONTENT_TYPE]) {
        headers[HTTP_HEADER_CONTENT_TYPE] =@"text/plain;charset=UTF-8";
    }
    if (!headers[HTTP_HEADER_ACCEPT]) {
        headers[HTTP_HEADER_ACCEPT]=@"*/*";
    }
    if (!headers[X_CA_TIMESTAMP]) {
        headers[X_CA_TIMESTAMP]=[NSString stringWithFormat:@"%lld",[num longLongValue]];
    }
    headers[X_CA_KEY]=appKey;
    headers[X_CA_SIGNATURE]=[GA_ARO_SignUtil signWithSecret:appSecret
                                                          method:method
                                                            path:path
                                                         headers:headers
                                                          querys:querys
                                                           bodys:bodys
                                            signHeaderPrefixList:signHeaderPrefixList];

    return headers;

}




+ (NSString *)getUUID
{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    return uniqueId;
}


+(GA_ARO_HTTPSessionManager *)httpManager:(NSMutableDictionary<NSString *,NSString *> *)headers
                                  timeOut:(NSInteger)timeOut {
    __block GA_ARO_HTTPSessionManager *shareManger = [GA_ARO_HTTPSessionManager manager];
    shareManger.securityPolicy = [GA_ARO_SecurityPolicy policyWithPinningMode:GA_ARO_SSLPinningModeNone];
    shareManger.securityPolicy.allowInvalidCertificates = YES;
    shareManger.securityPolicy.validatesDomainName = NO;
    shareManger.requestSerializer.timeoutInterval = 20;
    shareManger.responseSerializer = [GA_ARO_HTTPResponseSerializer serializer];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [shareManger.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    return shareManger;
}


+ (NSString *)unicode2ISO8859:(NSString *)value {
    
    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    
    return [NSString stringWithCString:[value UTF8String] encoding:enc];
    
}


+(NSString*) urlEncode:(NSString *)url {
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
}

+(NSString*) urlDecode:(NSString *)url {
    return [url stringByRemovingPercentEncoding];
}

+(NSError *)hanlderErrorMsg:(NSError *)error{
    NSData *errorData = error.userInfo[@"GA_ARO_.com.alamofire.serialization.response.error.data"];
    NSString *str = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    dic[@"errorDes"]=str;
    [error setValue:dic forKey:@"userInfo"];
    return error;
}

@end
