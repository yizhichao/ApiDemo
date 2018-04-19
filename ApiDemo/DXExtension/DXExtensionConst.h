
#ifndef __DXExtensionConst__H__
#define __DXExtensionConst__H__

#import <Foundation/Foundation.h>

// 过期
#define DXExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define DXExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setDX_error:error];

// 日志输出
#ifdef DEBUG
#define DXExtensionLog(...) NSLog(__VA_ARGS__)
#else
#define DXExtensionLog(...)
#endif

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define DXExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setDX_error:nil]; \
if ((condition) == NO) { \
    DXExtensionBuildError(clazz, msg); \
    return returnValue;\
}

#define DXExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define DXExtensionAssert(condition) DXExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define DXExtensionAssertParamNotNil2(param, returnValue) \
DXExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define DXExtensionAssertParamNotNil(param) DXExtensionAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define DXLogAllIvars \
-(NSString *)description \
{ \
    return [self DX_keyValues].description; \
}
#define DXExtensionLogAllProperties DXLogAllIvars

/**
 *  类型（属性类型）
 */
extern NSString *const DXPropertyTypeInt;
extern NSString *const DXPropertyTypeShort;
extern NSString *const DXPropertyTypeFloat;
extern NSString *const DXPropertyTypeDouble;
extern NSString *const DXPropertyTypeLong;
extern NSString *const DXPropertyTypeLongLong;
extern NSString *const DXPropertyTypeChar;
extern NSString *const DXPropertyTypeBOOL1;
extern NSString *const DXPropertyTypeBOOL2;
extern NSString *const DXPropertyTypePointer;

extern NSString *const DXPropertyTypeIvar;
extern NSString *const DXPropertyTypeMethod;
extern NSString *const DXPropertyTypeBlock;
extern NSString *const DXPropertyTypeClass;
extern NSString *const DXPropertyTypeSEL;
extern NSString *const DXPropertyTypeId;

#endif