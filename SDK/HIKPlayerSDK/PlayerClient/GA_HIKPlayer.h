//
//  GA_HIKPlayer.h
//  HIKPlayerSDK
//
//  Created by wangyong14 on 2017/11/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GA_StreamClient.h"

@class GA_HIKPlayer;

/* 播放器DXPlayer的状态消息定义 */
typedef NS_ENUM(NSInteger, DX_MessageCode) {
    DX_PLAYER_VALIDATE_CODE_CANCEL  = -2, //视频加密验证码输入被取消
    DX_PLAYER_NEED_VALIDATE_CODE    = -1,   //播放需要安全验证
    DX_PLAYER_REALPLAY_START        = 1,        //直播开始
    DX_PLAYER_VIDEOLEVEL_CHANGE     = 2,     //直播流清晰度切换中
    DX_PLAYER_STREAM_RECONNECT      = 3,      //直播流取流正在重连
    DX_PLAYER_VOICE_TALK_START      = 4,      //对讲开始
    DX_PLAYER_VOICE_TALK_END        = 5,        //对讲结束
    DX_PLAYER_STREAM_START          = 10,         //录像取流开始
    DX_PLAYER_PLAYBACK_START        = 11,       //录像回放开始播放
    DX_PLAYER_PLAYBACK_END          = 12,         //录像回放结束播放
    DX_PLAYER_PLAYBACK_FINISHED     = 13,    //录像回放被用户强制中断
    DX_PLAYER_PLAYBACK_PAUSE        = 14,       //录像回放暂停
};

@protocol GA_HIKPlayerDelegate <NSObject>

- (void)player:(GA_HIKPlayer *)player didPlayFailed:(NSError *)error;

- (void)player:(GA_HIKPlayer *)player didReceviedMessage:(DX_MessageCode)messageCode;

- (void)player:(GA_HIKPlayer *) player didReceivedDataLength:(NSInteger)dataLength;

@end

@interface GA_HIKPlayer : NSObject

+(GA_HIKPlayer *)createPlayerWith:(NSString *)url;

+(GA_HIKPlayer *)createPlayerWithurlBlock:(NSString *(^)(void))urlBlock;

- (BOOL)startRealPlay;

- (BOOL)pauseRealPlay;

- (BOOL)resumeRealPlay;

- (BOOL)stopRealPlay;

- (void)setPlayerView:(UIView *)playerView;

@property (nonatomic, weak) id<GA_HIKPlayerDelegate> delegate;

@end
