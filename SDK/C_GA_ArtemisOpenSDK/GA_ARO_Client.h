//
//  GA_ARO_Client.h
//  C_GA_ArtemisSDK
//
//  Created by wangyong14 on 2017/11/22.
//

#import <Foundation/Foundation.h>
#import "GA_ARO_Request.h"
#import "GA_ARO_Response.h"

@interface GA_ARO_Client : NSObject

+(void)get:(GA_ARO_Request *)request completion:(void (^)(GA_ARO_Response *response,NSError *error))completion;

+(void)post:(GA_ARO_Request *)request completion:(void (^)(GA_ARO_Response *response,NSError *error))completion;

@end
