//
//  LoginViewController.h
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *appSecretTextField;

@end
