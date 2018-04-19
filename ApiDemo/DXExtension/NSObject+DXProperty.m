//
//  NSObject+DXProperty.m
//  DXExtensionExample
//
//  Created by DX Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+DXProperty.h"
#import "NSObject+DXKeyValue.h"
#import "NSObject+DXCoding.h"
#import "NSObject+DXClass.h"
#import "DXProperty.h"
#import "DXFoundation.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static const char DXReplacedKeyFromPropertyNameKey = '\0';
static const char DXReplacedKeyFromPropertyName121Key = '\0';
static const char DXNewValueFromOldValueKey = '\0';
static const char DXObjectClassInArrayKey = '\0';

static const char DXCachedPropertiesKey = '\0';

@implementation NSObject (Property)

static NSMutableDictionary *dxreplacedKeyFromPropertyNameDict_;
static NSMutableDictionary *dxreplacedKeyFromPropertyName121Dict_;
static NSMutableDictionary *dxnewValueFromOldValueDict_;
static NSMutableDictionary *dxobjectClassInArrayDict_;
static NSMutableDictionary *dxcachedPropertiesDict_;

+ (void)load
{
    dxreplacedKeyFromPropertyNameDict_ = [NSMutableDictionary dictionary];
    dxreplacedKeyFromPropertyName121Dict_ = [NSMutableDictionary dictionary];
    dxnewValueFromOldValueDict_ = [NSMutableDictionary dictionary];
    dxobjectClassInArrayDict_ = [NSMutableDictionary dictionary];
    dxcachedPropertiesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dxdictForKey:(const void *)key
{
    @synchronized (self) {
        if (key == &DXReplacedKeyFromPropertyNameKey) return dxreplacedKeyFromPropertyNameDict_;
        if (key == &DXReplacedKeyFromPropertyName121Key) return dxreplacedKeyFromPropertyName121Dict_;
        if (key == &DXNewValueFromOldValueKey) return dxnewValueFromOldValueDict_;
        if (key == &DXObjectClassInArrayKey) return dxobjectClassInArrayDict_;
        if (key == &DXCachedPropertiesKey) return dxcachedPropertiesDict_;
        return nil;
    }
}

#pragma mark - --私有方法--
+ (id)dxpropertyKey:(NSString *)propertyName
{
    DXExtensionAssertParamNotNil2(propertyName, nil);
    
    __block id key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(DX_replacedKeyFromPropertyName121:)]) {
        key = [self DX_replacedKeyFromPropertyName121:propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName121:)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName121) withObject:propertyName];
    }
    
    // 调用block
    if (!key) {
        [self DX_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            DXReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &DXReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(DX_replacedKeyFromPropertyName)]) {
        key = [self DX_replacedKeyFromPropertyName][propertyName];
    }
    // 兼容旧版本
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName)][propertyName];
    }
    
    if (!key || [key isEqual:propertyName]) {
        [self DX_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &DXReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key && ![key isEqual:propertyName]) *stop = YES;
        }];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)dxpropertyObjectClassInArray:(NSString *)propertyName
{
    __block id clazz = nil;
    if ([self respondsToSelector:@selector(DX_objectClassInArray)]) {
        clazz = [self DX_objectClassInArray][propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        clazz = [self performSelector:@selector(objectClassInArray)][propertyName];
    }
    
    if (!clazz) {
        [self DX_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &DXObjectClassInArrayKey);
            if (dict) {
                clazz = dict[propertyName];
            }
            if (clazz) *stop = YES;
        }];
    }
    
    // 如果是NSString类型
    if ([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    return clazz;
}

#pragma mark - --公共方法--
+ (void)DX_enumerateProperties:(DXPropertiesEnumeration)enumeration
{
    // 获得成员变量
    NSArray *cachedProperties = [self dxproperties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (DXProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

#pragma mark - 公共方法
+ (NSMutableArray *)dxproperties
{
    NSMutableArray *cachedProperties = [self dxdictForKey:&DXCachedPropertiesKey][NSStringFromClass(self)];
    
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self DX_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                DXProperty *property = [DXProperty cachedPropertyWithProperty:properties[i]];
                // 过滤掉Foundation框架类里面的属性
                if ([DXFoundation isClassFromFoundation:property.srcClass]) continue;
                property.srcClass = c;
                [property setOriginKey:[self dxpropertyKey:property.name] forClass:self];
                [property setObjectClassInArray:[self dxpropertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        
        [self dxdictForKey:&DXCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
    }
    
    return cachedProperties;
}

#pragma mark - 新值配置
+ (void)DX_setupNewValueFromOldValue:(DXNewValueFromOldValue)newValueFormOldValue
{
    objc_setAssociatedObject(self, &DXNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)DX_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(DXProperty *__unsafe_unretained)property{
    // 如果有实现方法
    if ([object respondsToSelector:@selector(DX_newValueFromOldValue:property:)]) {
        return [object DX_newValueFromOldValue:oldValue property:property];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(newValueFromOldValue:property:)]) {
        return [self performSelector:@selector(newValueFromOldValue:property:)  withObject:oldValue  withObject:property];
    }
    
    // 查看静态设置
    __block id newValue = oldValue;
    [self DX_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        DXNewValueFromOldValue block = objc_getAssociatedObject(c, &DXNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)DX_setupObjectClassInArray:(DXObjectClassInArray)objectClassInArray
{
    [self DX_setupBlockReturnValue:objectClassInArray key:&DXObjectClassInArrayKey];
    
    [[self dxdictForKey:&DXCachedPropertiesKey] removeAllObjects];
}

#pragma mark - key配置
+ (void)DX_setupReplacedKeyFromPropertyName:(DXReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self DX_setupBlockReturnValue:replacedKeyFromPropertyName key:&DXReplacedKeyFromPropertyNameKey];
    
    [[self dxdictForKey:&DXCachedPropertiesKey] removeAllObjects];
}

+ (void)DX_setupReplacedKeyFromPropertyName121:(DXReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    objc_setAssociatedObject(self, &DXReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [[self dxdictForKey:&DXCachedPropertiesKey] removeAllObjects];
}
@end

#pragma clang diagnostic pop
