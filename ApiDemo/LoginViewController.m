//
//  LoginViewController.m
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import "LoginViewController.h"
#import "ApiConfig.h"
#import "CameraListTableViewController.h"
#import "C_GA_Open8200SDK.h"

@implementation LoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [GAOpen8200ApiClient sharedInstance];
}

- (IBAction)LoginAction:(UIButton *)sender {
    
    if (self.hostTextField.text && self.appKeyTextField.text) {
        [ApiConfig shareConfig].host = self.hostTextField.text;
        [ApiConfig shareConfig].appKey = self.appKeyTextField.text;
        [ApiConfig shareConfig].appSecret = self.appSecretTextField.text;
        NSString *host = [@"https://" stringByAppendingString:self.hostTextField.text];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:host forKey:@"host"];
        [dic setObject:self.appKeyTextField.text forKey:@"appKey"];
        [dic setObject:self.appSecretTextField.text forKey:@"appSecret"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DXLOGIN_SUCCESS"
                                                            object:dic];
        CameraListTableViewController *vc = [[CameraListTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
