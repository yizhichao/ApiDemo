//
//  NSObject+DXClass.m
//  DXExtensionExample
//
//  Created by DX Lee on 15/8/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+DXClass.h"
#import "NSObject+DXCoding.h"
#import "NSObject+DXKeyValue.h"
#import "DXFoundation.h"
#import <objc/runtime.h>

static const char DXAllowedPropertyNamesKey = '\0';
static const char DXIgnoredPropertyNamesKey = '\0';
static const char DXAllowedCodingPropertyNamesKey = '\0';
static const char DXIgnoredCodingPropertyNamesKey = '\0';

static NSMutableDictionary *dxallowedPropertyNamesDict_;
static NSMutableDictionary *dxignoredPropertyNamesDict_;
static NSMutableDictionary *dxallowedCodingPropertyNamesDict_;
static NSMutableDictionary *dxignoredCodingPropertyNamesDict_;

@implementation NSObject (DXClass)

+ (void)load
{
    dxallowedPropertyNamesDict_ = [NSMutableDictionary dictionary];
    dxignoredPropertyNamesDict_ = [NSMutableDictionary dictionary];
    dxallowedCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
    dxignoredCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    @synchronized (self) {
        if (key == &DXAllowedPropertyNamesKey) return dxallowedPropertyNamesDict_;
        if (key == &DXIgnoredPropertyNamesKey) return dxignoredPropertyNamesDict_;
        if (key == &DXAllowedCodingPropertyNamesKey) return dxallowedCodingPropertyNamesDict_;
        if (key == &DXIgnoredCodingPropertyNamesKey) return dxignoredCodingPropertyNamesDict_;
        return nil;
    }
}

+ (void)DX_enumerateClasses:(DXClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([DXFoundation isClassFromFoundation:c]) break;
    }
}

+ (void)DX_enumerateAllClasses:(DXClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
    }
}

#pragma mark - 属性黑名单配置
+ (void)DX_setupIgnoredPropertyNames:(DXIgnoredPropertyNames)ignoredPropertyNames
{
    [self DX_setupBlockReturnValue:ignoredPropertyNames key:&DXIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)DX_totalIgnoredPropertyNames
{
    return [self DX_totalObjectsWithSelector:@selector(DX_ignoredPropertyNames) key:&DXIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置
+ (void)DX_setupIgnoredCodingPropertyNames:(DXIgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self DX_setupBlockReturnValue:ignoredCodingPropertyNames key:&DXIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)DX_totalIgnoredCodingPropertyNames
{
    return [self DX_totalObjectsWithSelector:@selector(DX_ignoredCodingPropertyNames) key:&DXIgnoredCodingPropertyNamesKey];
}

#pragma mark - 属性白名单配置
+ (void)DX_setupAllowedPropertyNames:(DXAllowedPropertyNames)allowedPropertyNames;
{
    [self DX_setupBlockReturnValue:allowedPropertyNames key:&DXAllowedPropertyNamesKey];
}

+ (NSMutableArray *)DX_totalAllowedPropertyNames
{
    return [self DX_totalObjectsWithSelector:@selector(DX_allowedPropertyNames) key:&DXAllowedPropertyNamesKey];
}

#pragma mark - 归档属性白名单配置
+ (void)DX_setupAllowedCodingPropertyNames:(DXAllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self DX_setupBlockReturnValue:allowedCodingPropertyNames key:&DXAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)DX_totalAllowedCodingPropertyNames
{
    return [self DX_totalObjectsWithSelector:@selector(DX_allowedCodingPropertyNames) key:&DXAllowedCodingPropertyNamesKey];
}
#pragma mark - block和方法处理:存储block的返回值
+ (void)DX_setupBlockReturnValue:(id (^)())block key:(const char *)key
{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 清空数据
    [[self dictForKey:key] removeAllObjects];
}

+ (NSMutableArray *)DX_totalObjectsWithSelector:(SEL)selector key:(const char *)key
{
    NSMutableArray *array = [self dictForKey:key][NSStringFromClass(self)];
    if (array) return array;
    
    // 创建、存储
    [self dictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
        if (subArray) {
            [array addObjectsFromArray:subArray];
        }
    }
    
    [self DX_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}
@end
