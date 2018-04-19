#ifndef __DXExtensionConst__M__
#define __DXExtensionConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const DXPropertyTypeInt = @"i";
NSString *const DXPropertyTypeShort = @"s";
NSString *const DXPropertyTypeFloat = @"f";
NSString *const DXPropertyTypeDouble = @"d";
NSString *const DXPropertyTypeLong = @"l";
NSString *const DXPropertyTypeLongLong = @"q";
NSString *const DXPropertyTypeChar = @"c";
NSString *const DXPropertyTypeBOOL1 = @"c";
NSString *const DXPropertyTypeBOOL2 = @"b";
NSString *const DXPropertyTypePointer = @"*";

NSString *const DXPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const DXPropertyTypeMethod = @"^{objc_method=}";
NSString *const DXPropertyTypeBlock = @"@?";
NSString *const DXPropertyTypeClass = @"#";
NSString *const DXPropertyTypeSEL = @":";
NSString *const DXPropertyTypeId = @"@";

#endif