//
//  PlayerViewController.m
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import "PlayerViewController.h"
#import "C_GA_Open8200SDK.h"
#import "HIKPlayerSDK.h"
#import "CameraInfo.h"


@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.cameraInfo.name;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player stopRealPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)setCameraInfo:(CameraInfo *)cameraInfo {
    
    _cameraInfo = cameraInfo;
    [self.player startRealPlay];
}

- (GA_HIKPlayer *)player {
    
    if (!_player) {
        _player = [GA_HIKPlayer createPlayerWithurlBlock:^NSString *{
            __block NSString *url = @"";
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [GAOpen8200ApiClient getRealPlayRtspURL:self.cameraInfo.indexCode completion:^(NSString *rtspUrl, NSError *error) {
                url = rtspUrl;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            return url;
        }];
        [_player setPlayerView:self.view];
    }
    return _player;
}

@end
