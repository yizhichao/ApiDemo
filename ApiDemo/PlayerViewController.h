//
//  PlayerViewController.h
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CameraInfo;
@class GA_HIKPlayer;

@interface PlayerViewController : UIViewController

@property (nonatomic, strong) CameraInfo *cameraInfo;

@property (nonatomic, strong) GA_HIKPlayer *player;

@end
