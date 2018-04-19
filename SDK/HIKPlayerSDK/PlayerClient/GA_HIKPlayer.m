//
//  GA_HIKPlayer.m
//  HIKPlayerSDK
//
//  Created by wangyong14 on 2017/11/11.
//

#import "GA_HIKPlayer.h"
#import <PlayCtrl/IOSPlayM4.h>
#import "NSDate+HIKPlayerSDK.h"
#import <UIKit/UIKit.h>
//#import <C_GA_Open8200SDK/C_GA_Open8200SDK.h>


#define INVALID_PORT    (-1)
#define DATATYPE_HEADER                        1        //头数据
#define DATATYPE_STREAM                        2        //流数据
#define STREAM_PLAYBACK_FINISH                 0x0064       // 回放、下载或倒放结束标识
#define PLAY_DATA_BUFF  (1024*1024*5)   //播放缓存

//由于加入录像分片功能，需要播放库回调帧信息，故此函数废弃，暂时不用
void preRecordCallBack(int nPort,void* pData,unsigned int nDataLen,void *pUser);
void preRecordCallBack(int nPort,void* pData,unsigned int nDataLen,void *pUser){
    NSLog(@"录像数据回调********");
    NSData *data = [NSData dataWithBytes:pData length:nDataLen];
    if(NO == [(__bridge id)pUser isKindOfClass:[GA_HIKPlayer class]])
    {
        return;
    }
    GA_HIKPlayer *hikPlayer = (__bridge GA_HIKPlayer *)pUser;
    void(^recordData)(NSData *) = [hikPlayer performSelector:@selector(recordDataBlock)];
    if (recordData) {
        recordData(data);
    }
}

//播放库显示回调
void displayCallback(DISPLAY_INFO *pstDisplayInfo);
void displayCallback(DISPLAY_INFO *pstDisplayInfo)
{
    NSLog(@"^^^^^播放回调displayCallback…………………………");
    if(NO == [(__bridge id)pstDisplayInfo->nUser isKindOfClass:[GA_HIKPlayer class]]){
        return;
    }
    GA_HIKPlayer *hikPlayer = (__bridge GA_HIKPlayer *)pstDisplayInfo->nUser;
    NSString *playPort =[hikPlayer performSelector:@selector(getPlayPort)];
    PlayM4_SetDisplayCallBackEx([playPort intValue], NULL, 0);
    
    NSString *isRealPlay =[hikPlayer performSelector:@selector(getIsRealPlay)];
    
    [hikPlayer performSelector:@selector(startTimer)];
    //刷新播放器，便于OSDTime正确
//    PlayM4_RefreshPlay([playPort intValue]);
//    PlayM4_Pause([playPort intValue], 0);
 
    
    if ([hikPlayer.delegate respondsToSelector:@selector(player:didReceviedMessage:)]) {
        if ([isRealPlay isEqualToString:@"1"]) {
            [hikPlayer.delegate player:hikPlayer
                    didReceviedMessage:DX_PLAYER_REALPLAY_START];
        }else{
            
            [hikPlayer.delegate player:hikPlayer
                    didReceviedMessage:DX_PLAYER_PLAYBACK_START];
        }
    }
    [hikPlayer performSelector:@selector(startTimer)];
};


void videoFileEndCallback(int nPort, void *pUser)
{
    GA_HIKPlayer *hikPlayer = (__bridge GA_HIKPlayer *)pUser;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([hikPlayer.delegate respondsToSelector:@selector(player:didReceviedMessage:)]) {
            [hikPlayer.delegate player:hikPlayer
                    didReceviedMessage:DX_PLAYER_PLAYBACK_END];
        }
    });
}

void videoFilePlayRefCallBack(int nPort,void* nUser)
{
    
}


@interface GA_HIKPlayer()<GA_StreamClientDelegate>

@property (nonatomic,strong) GA_StreamClient *streamClient;

//播放视频的view
@property (nonatomic,weak)   UIView  *playerView;

//取流的URL包含回放与预览
@property (nonatomic,strong) NSString *streamUrl;

//播放通道标识符
@property (nonatomic,assign) int  playPort;

//录像数据回调的Block
@property (nonatomic, copy)  void (^recordDataBlock)(NSData *data);

@property (nonatomic, copy)  NSString* (^urlBlock)();


@property(nonatomic,assign)  BOOL isRealPlay;

@property(nonatomic,strong) dispatch_source_t  receivedDataLengthTimer;

//所有跟流相关的操作都需要放到这个队列处理，不然容易出问题
@property (nonatomic,strong) dispatch_queue_t GA_HIKPlayer_PlayQueue;

@property (nonatomic,strong) dispatch_queue_t GA_HIKPlayer_DataQueue;

@property (nonatomic,strong) dispatch_queue_t GA_HIKPlayer_OptionQueue;

@property (nonatomic,strong) dispatch_semaphore_t GA_HIKPlayer_PlaySemaphore;

@property (nonatomic,strong) dispatch_semaphore_t GA_HIKPlayer_DataSemaphore;

@property(nonatomic,strong) NSOperationQueue *playBackQueue;

@property(nonatomic,strong) NSOperationQueue *seekPlayBackQueue;


@property (nonatomic,assign) long totleFlow;//总的流量数据

@property (nonatomic,assign) long lastTotleFlow;//距离总的流量数据的前一秒数据

@property(nonatomic,assign)  BOOL isStartPlaybackFrom;

@end



@implementation GA_HIKPlayer

+(GA_HIKPlayer *)createPlayerWith:(NSString *)url{
    GA_HIKPlayer *hikPlayer = [GA_HIKPlayer new];
    [hikPlayer initWithUrl:url];
    return hikPlayer;
}



-(void)initWithUrl:(NSString *)url{
    self.streamUrl = url;
    self.playPort = INVALID_PORT;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // 软件取消活跃通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}


+(GA_HIKPlayer *)createPlayerWithurlBlock:(NSString *(^)())urlBlock{
    GA_HIKPlayer *hikPlayer =  [GA_HIKPlayer new];
    hikPlayer.urlBlock = urlBlock;
    [hikPlayer GA_HIKPlayer_OptionQueue];
    return hikPlayer;
}




-(void)handleDidEnterBackgroundNotification:(NSNotification *)notification{
    if (self.isRealPlay) {
        [self stopRealPlay];
    }else{
        [self pausePlayback];
    }
}

-(void)handleWillResignActiveNotification:(NSNotification *)notification{
    if (self.isRealPlay) {
        [self stopRealPlay];
    }else{
        [self pausePlayback];
    }
}

-(void)setPlayerView:(UIView *)playerView{
    _playerView = playerView;
}

//-(BOOL)openSound{
//    PlayM4_PlaySound(self.playPort);
//    return YES;
//}
//
//-(BOOL)closeSound{
//    PlayM4_StopSound();
//    return YES;
//}

#pragma mark - 预览相关接口
-(BOOL)startRealPlay{
    
    
    self.isRealPlay = YES;
    
    if (!self.streamUrl) {
        if (!self.urlBlock) {
            return NO;
        }
    }
    dispatch_async(self.GA_HIKPlayer_OptionQueue, ^{
        
        self.streamUrl = self.urlBlock();
        
        if (!self.streamUrl||self.streamUrl.length==0) {
            NSError *error  = [self getError:@"预览url不能为空" code:500];
            [self delegateDidPlayFailed:error];
            return;
        }
        
        [self initWithUrl:self.streamUrl];
        
        [self stopPlayPort];
        
        PlayM4_SetDisplayCallBackEx(self.playPort, &displayCallback, (__bridge void*)self);
        
        if (!self.streamClient) {
            self.streamClient = [GA_StreamClient initWithPlayUrl:self.streamUrl
                                                        delegate:self];
        }
        dispatch_async(self.GA_HIKPlayer_PlayQueue, ^{
            NSError *error = [self.streamClient startGetRealPlayStream];
            [self delegateDidPlayFailed:error];
            dispatch_semaphore_signal(self.GA_HIKPlayer_PlaySemaphore);
        });
        dispatch_semaphore_wait(self.GA_HIKPlayer_PlaySemaphore, DISPATCH_TIME_FOREVER);
    });
    return YES;
}

-(BOOL)stopRealPlay{
    dispatch_async(self.GA_HIKPlayer_OptionQueue, ^{
        dispatch_async(self.GA_HIKPlayer_PlayQueue, ^{
            [self stopTimer];
            [self stopPlayPort];
            [self.streamClient stopGetStream];
            dispatch_semaphore_signal(self.GA_HIKPlayer_PlaySemaphore);
        });
        dispatch_semaphore_wait(self.GA_HIKPlayer_PlaySemaphore, DISPATCH_TIME_FOREVER);
    });
    return YES;
}

#pragma mark - 回放相关接口

-(BOOL)startPlaybackFrom:(NSDate *)beginTime
                 endTime:(NSDate *)endTime{
    
    if (!self.streamUrl) {
        if (!self.urlBlock) {
            return NO;
        }
    }
    self.isRealPlay= NO;

    NSBlockOperation *playBackOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (self.urlBlock) {
            self.streamUrl = self.urlBlock();
        }
        if (!self.streamUrl||self.streamUrl.length==0) {
            NSError *error  = [self getError:@"回放url不能为空" code:500];
            [self delegateDidPlayFailed:error];
            return;
        }
        
        [self stopPlayPort];
        
        [self initWithUrl:self.streamUrl];
        
        PlayM4_SetDisplayCallBackEx(self.playPort, &displayCallback, (__bridge void*)self);
        
        dispatch_async(self.GA_HIKPlayer_PlayQueue, ^{
            NSLog(@"开始回放了---------start");
            [self.streamClient stopGetStream];
            
            self.streamClient = [GA_StreamClient initWithPlayUrl:self.streamUrl
                                                        delegate:self];
            NSError *error  = [self.streamClient startGetPlayBackStream:beginTime to:endTime];
            
            [self delegateDidPlayFailed:error];
            dispatch_semaphore_signal(self.GA_HIKPlayer_PlaySemaphore);
        });
        dispatch_semaphore_wait(self.GA_HIKPlayer_PlaySemaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"开始回放了----------end");
    }];
    
    [self.playBackQueue cancelAllOperations];
    [self.playBackQueue addOperation:playBackOperation];
    
    return YES;
    
}

- (BOOL)pausePlayback{
    
    [self stopTimer];
    dispatch_async(self.GA_HIKPlayer_OptionQueue, ^{
        PlayM4_Pause(self.playPort, 1);
        dispatch_async(self.GA_HIKPlayer_PlayQueue, ^{
            NSError *error = [self.streamClient pauseGetStream];
            //如果还没有开始播放，会存在这种情况
            [self delegateDidPlayFailed:error];
            if (!error) {
                [self delegatedidReceviedMessage:DX_PLAYER_PLAYBACK_PAUSE];
            }
            dispatch_semaphore_signal(self.GA_HIKPlayer_PlaySemaphore);
        });
        dispatch_semaphore_wait(self.GA_HIKPlayer_PlaySemaphore, DISPATCH_TIME_FOREVER);
    });
    return YES;
}

- (BOOL)resumePlayback{
    
    dispatch_async(self.GA_HIKPlayer_OptionQueue, ^{
        PlayM4_Pause(self.playPort, 0);
        dispatch_async(self.GA_HIKPlayer_PlayQueue, ^{
            NSError *error = [self.streamClient resumeGetStream];
            PlayM4_RefreshPlay(self.playPort);
            PlayM4_SetDisplayCallBackEx(self.playPort, &displayCallback, (__bridge void*)self);
            [self delegateDidPlayFailed:error];
            dispatch_semaphore_signal(self.GA_HIKPlayer_PlaySemaphore);
        });
        dispatch_semaphore_wait(self.GA_HIKPlayer_PlaySemaphore, DISPATCH_TIME_FOREVER);
    });
    return YES;
}

-(NSDate *)getOSDTime{
    
    if (self.playPort == INVALID_PORT)
    {
        return nil;
    }
    PLAYM4_SYSTEM_TIME sysTime = { 0 };
    //在没有播放的时候会获取不成功
    if (1 != PlayM4_GetSystemTime(self.playPort, &sysTime))
    {
        return nil;
    }
    NSDate *date = [NSDate dateWithYear:sysTime.dwYear
                                  month:sysTime.dwMon
                                    day:sysTime.dwDay
                                   hour:sysTime.dwHour
                                 minute:sysTime.dwMin
                                 second:sysTime.dwSec];
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //    NSInteger interval = [zone secondsFromGMTForDate: date];
    //    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return date;
}




-(BOOL)destoryPlayer{
    [self stopPlayPort];
    dispatch_async(self.GA_HIKPlayer_DataQueue, ^{
        [self.streamClient destoryStreamClient];
    });
    return YES;
}


#pragma mark - 播放器相关处理
-(void)hanlderStream:(NSInteger)dataType data:(char*) data len:(NSInteger)len{
    dispatch_async(self.GA_HIKPlayer_DataQueue, ^{
        if (dataType == DATATYPE_HEADER){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self initPlayerPort];
                PlayM4_SetStreamOpenMode(self.playPort, STREAME_REALTIME);
                PlayM4_OpenStream(self.playPort, (unsigned char *)data,len, PLAY_DATA_BUFF);
#pragma mark - 设置播放器的回调************************
                PlayM4_SetDisplayCallBackEx(self.playPort, &displayCallback, (__bridge void*)self);
                PlayM4_SetFileEndCallback(self.playPort, &videoFileEndCallback, (__bridge void*)self);
                //设置播放的View
                PlayM4_Play(self.playPort, (__bridge void *)self.playerView);
            });
        }else if (dataType == DATATYPE_STREAM){
            PlayM4_InputData(self.playPort,(unsigned char *) data, len);
        }else if (dataType == STREAM_PLAYBACK_FINISH) {
            [self delegatedidReceviedMessage:DX_PLAYER_PLAYBACK_END];
        }
        dispatch_semaphore_signal(self.GA_HIKPlayer_DataSemaphore);
    });
    dispatch_semaphore_wait(self.GA_HIKPlayer_DataSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)stopPlayPort
{
   
    @synchronized(self) {
        if ([NSThread isMainThread]) {
            if(self.playPort != INVALID_PORT)
            {
                PlayM4_Stop(self.playPort);
                PlayM4_ResetBuffer(self.playPort, 0);
                PlayM4_ResetBuffer(self.playPort, 1);
                PlayM4_ResetBuffer(self.playPort, 2);
                PlayM4_CloseStream(self.playPort);
                PlayM4_FreePort(self.playPort);
            }
            self.playPort = INVALID_PORT;
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(self.playPort != INVALID_PORT)
                {
                    PlayM4_Stop(self.playPort);
                    PlayM4_ResetBuffer(self.playPort, 0);
                    PlayM4_ResetBuffer(self.playPort, 1);
                    PlayM4_ResetBuffer(self.playPort, 2);
                    PlayM4_CloseStream(self.playPort);
                    PlayM4_FreePort(self.playPort);
                }
                self.playPort = INVALID_PORT;
            });
        }
    };
}

-(void)initPlayerPort{
    if (self.playPort==INVALID_PORT) {
        PlayM4_GetPort(&_playPort);
    }
#if TARGET_OS_SIMULATOR
    
#else
    BOOL smartEnable = NO;
    //真机才有的函数
    PlayM4_RenderPrivateData(_playPort, PLAYM4_RENDER_ANA_INTEL_DATA,smartEnable ? true : false);//7.3.2版本播放库新增功能，默认关闭智能分析
    PlayM4_RenderPrivateData(_playPort, PLAYM4_RENDER_MD, smartEnable ? true : false);//7.3.2版本播放库新增功能，默认关闭移动侦测
    PlayM4_RenderPrivateData(_playPort, PLAYM4_RENDER_FIRE_DETCET, smartEnable ? true : false);//7.3.2版本播放库新增功能，默认关闭热成像信息
    PlayM4_SetHDPriority(self.playPort); //TODO:存在硬解不了的情况下切换软解，录像数据回调得等软解成功后才能回上来
#endif
    
}


#pragma mark -GA_StreamClient 取流的回调
-(void)GA_StreamClient:(GA_StreamClient *) client
              dataType:(NSInteger) dataType
                  data:(char*) data
                   len:(NSInteger) len
                 error:(NSError *)error{
    self.totleFlow += len;
    if (error) {
        [self delegateDidPlayFailed:error];
        return;
    }
    [self hanlderStream:dataType data:data len:len];
    NSLog(@"~^~ datatype:%d", dataType);
}


-(NSError *)getError:(NSString *)method code:(NSInteger) code{
    NSError *error = [NSError errorWithDomain:@"HIKPlayerSDK_____GA_HIKPlayer" code:code userInfo:@{NSLocalizedDescriptionKey:method}];
    return error;
}


#pragma mark - 刷新进度条定时任务相关处理
-(void)startTimer
{
    @synchronized (self) {
        [self stopTimer];
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        _receivedDataLengthTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_receivedDataLengthTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        //设置回调
        dispatch_source_set_event_handler(_receivedDataLengthTimer, ^{
            [self timerOption];
        });
        //启动timer
        dispatch_resume(_receivedDataLengthTimer);
    }
    
}


-(void)timerOption{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger dataLen = self.totleFlow -self.lastTotleFlow;
        if ([self.delegate respondsToSelector:@selector(player:didReceivedDataLength:)]) {
            [self.delegate player:self didReceivedDataLength:dataLen];
        }
        self.lastTotleFlow = self.totleFlow;
    });
}

-(void)stopTimer{
    self.totleFlow = 0;
    self.lastTotleFlow = 0;
    [self timerOption];
    
    if (!_receivedDataLengthTimer) {
        return;
    }
    dispatch_source_cancel(_receivedDataLengthTimer);//关闭
    _receivedDataLengthTimer = nil;
}




-(void)delegateDidPlayFailed:(NSError *)error{
    if (!error) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(player:didPlayFailed:)]) {
            [self.delegate player:self didPlayFailed:error];
        }
    });
}


-(void)delegatedidReceviedMessage:(NSInteger)code{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(player:didReceviedMessage:)]) {
            [self.delegate player:self
               didReceviedMessage:code];
        }
    });
}

-(dispatch_semaphore_t)GA_HIKPlayer_DataSemaphore{
    if (_GA_HIKPlayer_DataSemaphore) {
        return _GA_HIKPlayer_DataSemaphore;
    }
    _GA_HIKPlayer_DataSemaphore =dispatch_semaphore_create(0);
    return _GA_HIKPlayer_DataSemaphore;
}

-(dispatch_semaphore_t)GA_HIKPlayer_PlaySemaphore{
    if (_GA_HIKPlayer_PlaySemaphore) {
        return _GA_HIKPlayer_PlaySemaphore;
    }
    _GA_HIKPlayer_PlaySemaphore =dispatch_semaphore_create(0);
    return _GA_HIKPlayer_PlaySemaphore;
}

-(dispatch_queue_t)GA_HIKPlayer_OptionQueue{
    if (_GA_HIKPlayer_OptionQueue) {
        return _GA_HIKPlayer_OptionQueue;
    }
    NSString *strId = [NSString stringWithFormat:@"%@%@",@"GA_HIKPlayer_OptionQueue",[GA_HIKPlayer getUUID]];
    _GA_HIKPlayer_OptionQueue =  dispatch_queue_create([strId UTF8String], NULL);
    return _GA_HIKPlayer_OptionQueue;
}

-(dispatch_queue_t)GA_HIKPlayer_PlayQueue{
    if (_GA_HIKPlayer_PlayQueue) {
        return _GA_HIKPlayer_PlayQueue;
    }
    NSString *strId = [NSString stringWithFormat:@"%@%@",@"GA_HIKPlayer_PlayQueue",[GA_HIKPlayer getUUID]];
    _GA_HIKPlayer_PlayQueue =  dispatch_queue_create([strId UTF8String], NULL);
    return _GA_HIKPlayer_PlayQueue;
}

-(dispatch_queue_t)GA_HIKPlayer_DataQueue{
    if (_GA_HIKPlayer_DataQueue) {
        return _GA_HIKPlayer_DataQueue;
    }
    NSString *strId = [NSString stringWithFormat:@"%@%@",@"_GA_HIKPlayer_DataQueue",[GA_HIKPlayer getUUID]];
    _GA_HIKPlayer_DataQueue =  dispatch_queue_create([strId UTF8String], NULL);
    return _GA_HIKPlayer_DataQueue;
}

-(NSOperationQueue *)playBackQueue{
    if (_playBackQueue) {
        return _playBackQueue;
    }
    _playBackQueue = [NSOperationQueue new];
    [_playBackQueue setMaxConcurrentOperationCount:1];
    return _playBackQueue;
}

-(NSOperationQueue *)seekPlayBackQueue{
    if (_seekPlayBackQueue) {
        return _seekPlayBackQueue;
    }
    _seekPlayBackQueue = [NSOperationQueue new];
    [_seekPlayBackQueue setMaxConcurrentOperationCount:1];
    return _seekPlayBackQueue;
}

-(NSString *)getPlayPort{
    return [NSString stringWithFormat:@"%d",self.playPort];
}


-(NSString *)getIsRealPlay{
    return [NSString stringWithFormat:@"%d",self.isRealPlay];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.streamClient = nil;
}


+ (NSString *)getUUID
{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    return uniqueId;
}

@end
