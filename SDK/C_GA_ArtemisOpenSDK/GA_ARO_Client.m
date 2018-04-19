//
//  GA_ARO_Client.m
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/22.
//

#import "GA_ARO_Client.h"
#import "GA_ARO_HttpUtil.h"
#import "GA_ARO_Response.h"
#import "GA_ARO_HttpHeader.h"

@implementation GA_ARO_Client

+(void)get:(GA_ARO_Request *)request completion:(void (^)(GA_ARO_Response *, NSError *))completion{
    
    [request check];
    [GA_ARO_HttpUtil httpGet:request.host
                        path:request.path
                     timeOut:request.timeout
                     headers:request.headers
                      querys:request.querys
                      appkey:request.appKey
                   appSecret:request.appSecret completion:^(NSHTTPURLResponse * _Nonnull task,id  _Nullable responseObject, NSError *error) {
                       GA_ARO_Response *response = [self conver2Response:task data:responseObject];
                       if (completion) {
                           completion(response,error);
                       }
                   }];
}



+(void)post:(GA_ARO_Request *)request completion:(void (^)(GA_ARO_Response *, NSError *))completion{
    if (request.stringBody) {
        [GA_ARO_HttpUtil httpPost:request.host
                             path:request.path
                          timeOut:request.timeout
                          headers:request.headers
                             body:request.stringBody
                           appkey:request.appKey
                        appSecret:request.appSecret
                       completion:^(NSHTTPURLResponse *httpResponse, id  _Nullable responseObject, NSError *error) {
                           GA_ARO_Response *response = [self conver2Response:httpResponse data:responseObject];
                           if (completion) {
                               completion(response,error);
                           }
                       }];
    }
    if (request.querys) {
        [GA_ARO_HttpUtil httpPost:request.host
                             path:request.path
                          timeOut:request.timeout
                          headers:request.headers
                           querys:request.querys
                           appkey:request.appKey
                        appSecret:request.appSecret
                       completion:^(NSHTTPURLResponse *httpResponse, id  _Nullable responseObject, NSError *error) {
                           GA_ARO_Response *response = [self conver2Response:httpResponse data:responseObject];
                           if (completion) {
                               completion(response,error);
                           }
        }];
    }
    
}




+(GA_ARO_Response *)conver2Response:(NSHTTPURLResponse *)task data:(NSData *)responseObject{
    GA_ARO_Response *response = [GA_ARO_Response new];
    NSHTTPURLResponse *httpResponse = task;
    [response setStatusCode:httpResponse.statusCode];
    [response setHeaders:[httpResponse allHeaderFields]];
    [response setContentType:[httpResponse allHeaderFields][HTTP_HEADER_CONTENT_TYPE]];
    [response setRequestId:[httpResponse allHeaderFields][@"X-Ca-Request-Id"]];
    [response setErrorMessage:[httpResponse allHeaderFields][@"X-Ca-Error-Message"]];
    NSString *string =[[NSString alloc] initWithData:responseObject
                                            encoding:NSUTF8StringEncoding];
    [response setBody:string];
    return response;
    
}






@end
