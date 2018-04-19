//
//  GA_Atemis_Constants.h
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/20.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//签名算法HmacSha256
static NSString *const  HMAC_SHA256 = @"HmacSHA256";

//编码UTF-8
static NSString *const  ENCODING = @"UTF-8";

//UserAgent
static NSString *const  USER_AGENT = @"demo/aliyun/iOS";

//换行符
static NSString *const  LF = @"\n";

//串联符
static NSString *const  SPE1 = @",";

//示意符
static NSString *const  SPE2 = @":";

//连接符
static NSString *const  SPE3 = @"&";

//赋值符
static NSString *const  SPE4 = @"=";

//问号符
static NSString *const  SPE5 = @"?";

//默认请求超时时间,单位毫秒
static NSInteger   const  DEFAULT_TIMEOUT = 10000;

//参与签名的系统Header前缀,只有指定前缀的Header才会参与到签名中
static NSString *const  CA_HEADER_TO_SIGN_PREFIX_SYSTEM = @"x-ca-";
