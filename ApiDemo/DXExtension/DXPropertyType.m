//
//  DXPropertyType.m
//  DXExtension
//
//  Created by DX on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "DXPropertyType.h"
#import "DXExtension.h"
#import "DXFoundation.h"
#import "DXExtensionConst.h"

@implementation DXPropertyType

static NSMutableDictionary *types_;
+ (void)initialize
{
    types_ = [NSMutableDictionary dictionary];
}

+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    DXExtensionAssertParamNotNil2(code, nil);
    @synchronized (self) {
        DXPropertyType *type = types_[code];
        if (type == nil) {
            type = [[self alloc] init];
            type.code = code;
            types_[code] = type;
        }
        return type;
    }
}

#pragma mark - 公共方法
- (void)setCode:(NSString *)code
{
    _code = code;
    
    DXExtensionAssertParamNotNil(code);
    
    if ([code isEqualToString:DXPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [DXFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:DXPropertyTypeSEL] ||
               [code isEqualToString:DXPropertyTypeIvar] ||
               [code isEqualToString:DXPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[DXPropertyTypeInt, DXPropertyTypeShort, DXPropertyTypeBOOL1, DXPropertyTypeBOOL2, DXPropertyTypeFloat, DXPropertyTypeDouble, DXPropertyTypeLong, DXPropertyTypeLongLong, DXPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:DXPropertyTypeBOOL1]
            || [lowerCode isEqualToString:DXPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end
