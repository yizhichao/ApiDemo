//
//  NSObject+DXCoding.m
//  DXExtension
//
//  Created by DX on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "NSObject+DXCoding.h"
#import "NSObject+DXClass.h"
#import "NSObject+DXProperty.h"
#import "DXProperty.h"

@implementation NSObject (DXCoding)

- (void)DX_encode:(NSCoder *)encoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz DX_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz DX_totalIgnoredCodingPropertyNames];
    
    [clazz DX_enumerateProperties:^(DXProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)DX_decode:(NSCoder *)decoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz DX_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz DX_totalIgnoredCodingPropertyNames];
    
    [clazz DX_enumerateProperties:^(DXProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) { // 兼容以前的DXExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
