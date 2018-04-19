//
//  NSObject+DXCoding.h
//  DXExtension
//
//  Created by DX on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXExtensionConst.h"

/**
 *  Codeing协议
 */
@protocol DXCoding <NSObject>
@optional
/**
 *  这个数组中的属性名才会进行归档
 */
+ (NSArray *)DX_allowedCodingPropertyNames;
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSArray *)DX_ignoredCodingPropertyNames;
@end

@interface NSObject (DXCoding) <DXCoding>
/**
 *  解码（从文件中解析对象）
 */
- (void)DX_decode:(NSCoder *)decoder;
/**
 *  编码（将对象写入文件中）
 */
- (void)DX_encode:(NSCoder *)encoder;
@end

/**
 归档的实现
 */
#define DXCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self DX_decode:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self DX_encode:encoder]; \
}

#define DXExtensionCodingImplementation DXCodingImplementation