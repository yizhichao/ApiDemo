//
//  GA_ARO_Response.h
//  C_GA_ArtemisOpenSDK
//
//  Created by wangyong14 on 2017/11/22.
//

#import <Foundation/Foundation.h>

@interface GA_ARO_Response : NSObject

@property(nonatomic,assign)NSInteger  statusCode;

@property(nonatomic,copy) NSString *contentType;

@property(nonatomic,copy) NSString *requestId;

@property(nonatomic,copy) NSString *errorMessage;

@property(nonatomic,strong)NSMutableDictionary<NSString *,NSString *>  *headers;

@property(nonatomic,copy) NSString *body;

@end
