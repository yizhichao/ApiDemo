//
//  C_GA_ArtemisSignUtil.m
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/20.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import "GA_ARO_SignUtil.h"
#import "GA_ARO_Constants.h"
#import "GA_ARO_SystemHeader.h"
#import "GA_ARO_HttpHeader.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GA_ARO_HttpMethod.h"

@implementation GA_ARO_SignUtil




+(NSString *)signWithSecret:(NSString *)secret
                     method:(NSString *)method
                       path:(NSString *)path
                    headers:(NSMutableDictionary *)headers
                     querys:(NSMutableDictionary *)querys
                      bodys:(NSMutableDictionary *)bodys
       signHeaderPrefixList:(NSMutableArray<NSString *> *)signHeaderPrefixList{
    
    NSString *signString = [self buildStringToSign:method
                                              path:path
                                           headers:headers
                                            querys:querys
                                             bodys:bodys
                              signHeaderPrefixList:signHeaderPrefixList];
    
    
    const char *cKey = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [signString cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *base64Str =[hash base64EncodedStringWithOptions:0];
    
    return base64Str;
}



/**
 * 构建待签名字符串
 * @param method POST，GET
 * @param path url
 * @param headers  http协议头
 * @param querys 查询条件
 * @param bodys 查询条件
 * @param signHeaderPrefixList 自签名头
 */
+(NSString *)buildStringToSign:(NSString *)method
                          path:(NSString *)path
                       headers:(NSMutableDictionary *)headers
                        querys:(NSMutableDictionary *)querys
                         bodys:(NSMutableDictionary *)bodys
          signHeaderPrefixList:(NSMutableArray<NSString *> *)signHeaderPrefixList{
    __block NSString *sb = @"";
    sb = [NSString stringWithFormat:@"%@%@",sb,method.uppercaseString];
    sb = [NSString stringWithFormat:@"%@%@",sb,LF];
    if (headers) {
        if (headers[HTTP_HEADER_ACCEPT]) {
            sb = [NSString stringWithFormat:@"%@%@",sb,headers[HTTP_HEADER_ACCEPT]];
            sb = [NSString stringWithFormat:@"%@%@",sb,LF];
        }
        if (headers[HTTP_HEADER_CONTENT_MD5]) {
            sb = [NSString stringWithFormat:@"%@%@",sb,headers[HTTP_HEADER_CONTENT_MD5]];
            sb = [NSString stringWithFormat:@"%@%@",sb,LF];
        }
        if (headers[HTTP_HEADER_CONTENT_TYPE]) {
            sb = [NSString stringWithFormat:@"%@%@",sb,headers[HTTP_HEADER_CONTENT_TYPE]];
            sb = [NSString stringWithFormat:@"%@%@",sb,LF];
        }
        if (headers[HTTP_HEADER_DATE]) {
            sb = [NSString stringWithFormat:@"%@%@",sb,headers[HTTP_HEADER_DATE]];
            sb = [NSString stringWithFormat:@"%@%@",sb,LF];
        }
    }
    sb = [NSString stringWithFormat:@"%@%@",sb,[self buildHeaders:headers signHeaderPrefixList:signHeaderPrefixList]];

    if ([method isEqualToString:GET]) {
        sb = [NSString stringWithFormat:@"%@%@",sb,[self buildResource:path querys:querys bodys:bodys]];
    }else{
        sb = [NSString stringWithFormat:@"%@%@",sb,path];
    }

//    sb = [NSString stringWithFormat:@"%@%@",sb,[self buildResource:NO path:path querys:querys bodys:bodys]];

//    if ([method isEqualToString:GET]) {
//        sb = [NSString stringWithFormat:@"%@%@",sb,[self buildResource:NO path:path querys:querys bodys:bodys]];
//    }else{
//        sb = [NSString stringWithFormat:@"%@%@",sb,[self buildResource:YES path:path querys:querys bodys:bodys]];
//    }
    return sb;
}


/**
 * 构建待签名Path+Query+BODY
 *
 * @param path
 * @param querys
 * @param bodys
 * @return 待签名
 */
+(NSString *)buildResource:(NSString *)path
                    querys:(NSMutableDictionary<NSString *,NSString *> *)querys
                     bodys:(NSMutableDictionary<NSString *,NSString *> *)bodys{
    
    __block NSString *sb = @"";
    
    path = [path stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (path.length>0) {
        sb = [NSString stringWithFormat:@"%@%@",sb,path];
    }
    NSMutableDictionary *paramDic  = [NSMutableDictionary dictionaryWithDictionary:querys];
    [paramDic addEntriesFromDictionary:bodys];
    
    __block NSString *sbParam = @"";
    if (paramDic) {
        NSArray<NSString *> *allkeys = [paramDic allKeys];
        allkeys = [allkeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2];
        }];
        
        [allkeys enumerateObjectsUsingBlock:^(NSString * _Nonnull objKey, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = objKey; NSString *obj =paramDic[key];

            if (0 < sbParam.length) {
                sbParam = [NSString stringWithFormat:@"%@%@",sbParam,SPE3];
            }
            
            sbParam = [NSString stringWithFormat:@"%@%@",sbParam,objKey];
            
            if (obj&&obj.length>0) {
                sbParam = [NSString stringWithFormat:@"%@%@",sbParam,SPE4];
                sbParam = [NSString stringWithFormat:@"%@%@",sbParam,obj];
            }
        }];
    }
    
    if (0 < sbParam.length) {
        sb = [NSString stringWithFormat:@"%@%@",sb,SPE5];
        sb = [NSString stringWithFormat:@"%@%@",sb,sbParam];
    }
    
    return sb;
}


/**
 * 构建待签名Http头
 *
 * @param headers 请求中所有的Http头
 * @param signHeaderPrefixList 自定义参与签名Header前缀
 * @return 待签名Http头
 */
+(NSString *)buildHeaders:(NSMutableDictionary<NSString *,NSString *> *)headers
     signHeaderPrefixList:(NSMutableArray<NSString *> *) signHeaderPrefixList{
    
    __block NSString *sb = @"";
    
    if (signHeaderPrefixList) {
        [signHeaderPrefixList removeObject:X_CA_SIGNATURE];
        [signHeaderPrefixList removeObject:HTTP_HEADER_ACCEPT];
        [signHeaderPrefixList removeObject:HTTP_HEADER_CONTENT_TYPE];
        [signHeaderPrefixList removeObject:HTTP_HEADER_CONTENT_TYPE];
        [signHeaderPrefixList removeObject:HTTP_HEADER_DATE];
        signHeaderPrefixList = [signHeaderPrefixList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2];
        }];
    }
    
    if (headers) {
        __block NSString *signHeadersStringBuilder = @"";
        
        //由于字典是无序的，所以要进行排序
        NSArray<NSString *> *allkeys = [headers allKeys];
        allkeys = [allkeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2];
        }];
        
        [allkeys enumerateObjectsUsingBlock:^(NSString * _Nonnull objKey, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = objKey; NSString *obj =headers[key];
            obj = [obj stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([self isHeaderToSign:key signHeaderPrefixList:signHeaderPrefixList]) {
                
                sb = [NSString stringWithFormat:@"%@%@",sb,key];
                sb = [NSString stringWithFormat:@"%@%@",sb,SPE2];
                if (obj.length>0) {
                    sb = [NSString stringWithFormat:@"%@%@",sb,obj];
                }
                sb = [NSString stringWithFormat:@"%@%@",sb,LF];
                
                //http头里内容通过,拼接
                if (signHeadersStringBuilder.length>0) {
                    signHeadersStringBuilder = [NSString stringWithFormat:@"%@%@",signHeadersStringBuilder,SPE1];
                }
                signHeadersStringBuilder = [NSString stringWithFormat:@"%@%@",signHeadersStringBuilder,key];
            }
        }];
        headers[X_CA_SIGNATURE_HEADERS]=signHeadersStringBuilder;
    }
    return sb;
}


/**
 * Http头是否参与签名 return
 */
+(BOOL)isHeaderToSign:(NSString *) headerName
 signHeaderPrefixList:(NSArray<NSString *> *)signHeaderPrefixList{
    
    headerName = [headerName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!headerName||headerName.length==0) {
        return NO;
    }
    if ([headerName hasPrefix:CA_HEADER_TO_SIGN_PREFIX_SYSTEM]) {
        return YES;
    }
    
    if (!signHeaderPrefixList) {
        return NO;
    }
    
    __block BOOL result = NO;
    [signHeaderPrefixList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[headerName lowercaseString] isEqualToString:[obj lowercaseString]]) {
            result =  YES;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
