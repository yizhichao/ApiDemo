//
//  NSString+DXExtension.h
//  DXExtensionExample
//
//  Created by DX Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXExtensionConst.h"

@interface NSString (DXExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)DX_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)DX_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)DX_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)DX_firstCharLower;

- (BOOL)DX_isPureInt;

- (NSURL *)DX_url;
@end

@interface NSString (DXExtensionDeprecated_v_2_5_16)
- (NSString *)underlineFromCamel DXExtensionDeprecated("请在方法名前面加上DX_前缀，使用DX_***");
- (NSString *)camelFromUnderline DXExtensionDeprecated("请在方法名前面加上DX_前缀，使用DX_***");
- (NSString *)firstCharUpper DXExtensionDeprecated("请在方法名前面加上DX_前缀，使用DX_***");
- (NSString *)firstCharLower DXExtensionDeprecated("请在方法名前面加上DX_前缀，使用DX_***");
- (BOOL)isPureInt DXExtensionDeprecated("请在方法名前面加上DX_前缀，使用DX_***");
- (NSURL *)url DXExtensionDeprecated("请在方法名前面加上DX_前缀，使用DX_***");
@end
