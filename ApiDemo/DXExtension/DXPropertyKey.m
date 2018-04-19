//
//  DXPropertyKey.m
//  DXExtensionExample
//
//  Created by DX Lee on 15/8/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "DXPropertyKey.h"

@implementation DXPropertyKey

- (id)valueInObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]] && self.type == DXPropertyKeyTypeDictionary) {
        return object[self.name];
    } else if ([object isKindOfClass:[NSArray class]] && self.type == DXPropertyKeyTypeArray) {
        NSArray *array = object;
        NSUInteger index = self.name.intValue;
        if (index < array.count) return array[index];
        return nil;
    }
    return nil;
}
@end
