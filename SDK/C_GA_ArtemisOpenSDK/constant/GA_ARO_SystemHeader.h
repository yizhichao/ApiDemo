//
//  GA_Atemis_SystemHeader.h
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/20.
//  Copyright © 2017年 wangyong14. All rights reserved.
//

#ifndef GA_Atemis_SystemHeader_h
#define GA_Atemis_SystemHeader_h


#endif /* GA_Atemis_SystemHeader_h */


//签名Header
static NSString *const  X_CA_SIGNATURE           = @"x-ca-signature";

//所有参与签名的Header
static NSString *const  X_CA_SIGNATURE_HEADERS   = @"x-ca-signature-headers";

//请求时间戳
static NSString *const  X_CA_TIMESTAMP           = @"x-ca-timestamp";

//请求放重放Nonce,15分钟内保持唯一,建议使用UUID
static NSString *const  X_CA_NONCE               = @"x-ca-nonce";

//请求放重放Nonce,15分钟内保持唯一,建议使用UUID
static NSString *const  X_CA_KEY                 = @"x-ca-key";
