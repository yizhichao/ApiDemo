//
//  GA_StreamClient.m
//  Pods
//
//  Created by wangyong14 on 2017/11/11.
//

#import "GA_StreamClient.h"
#import <StreamClient/StreamClient.h>
#import "NSDate+HIKPlayerSDK.h"

#define INVALID_PORT    (-1)

#define HANLDER_SUCCESS (0)

int GA_StreamClient_RealPlay_RTSPDataCallback(int sessionhandle, void* userdata, int datatype, void* pdata, int datalen);
int GA_StreamClient_RealPlay_RTSPDataCallback(int sessionhandle, void* userdata, int datatype, void* pdata, int datalen)
{
    
    if(NO == [(__bridge id)userdata isKindOfClass:[GA_StreamClient class]])
    {
        return -1;
    }
    GA_StreamClient *streamClient = (__bridge GA_StreamClient *)userdata;
    
    if ([streamClient.delegate respondsToSelector:@selector(GA_StreamClient:dataType:data:len:error:)]) {
        [streamClient.delegate GA_StreamClient:streamClient
                                      dataType:datatype
                                          data:(char *)pdata
                                           len:datalen
                                         error:nil];
        
    }
    return 1;
}


int GA_StreamClient_RealPlay_RTSPMsgCallback(int sessionhandle, void* userdata, int errCode, void* param1, void* param2, void* param3, void* param4);
int GA_StreamClient_RealPlay_RTSPMsgCallback(int sessionhandle, void* userdata, int errCode, void* param1, void* param2, void* param3, void* param4)
{
    NSLog(@"*******GA_StreamClient_RealPlay_RTSPMsgCallback=%d",errCode);
    if(NO == [(__bridge id)userdata isKindOfClass:[GA_StreamClient class]])
    {
        return -1;
    }
    GA_StreamClient *streamClient = (__bridge GA_StreamClient *)userdata;
    if ([streamClient.delegate respondsToSelector:@selector(GA_StreamClient:dataType:data:len:error:)]) {
                NSError *error = [NSError errorWithDomain:@"GA_StreamClient_RTSPMsgCallback"
                                                     code:errCode
                                                 userInfo:@{NSLocalizedDescriptionKey:@""}];
                [streamClient.delegate GA_StreamClient:streamClient
                                              dataType:0
                                                  data:0
                                                   len:0
                                                 error:error];
        
    }
    return 0;
}



@interface GA_StreamClient()

@property (nonatomic,assign) int  rtspHandlerPort;//取流通道标识符

@property(nonatomic,strong) NSString *playUrl;//实际设备取流的URL，通过这个url找到内部实际取流的位置

@property(nonatomic,strong) NSDate *beginTime;//开始时间

@property(nonatomic,strong) NSDate *endTime;//录像片段的结束时间

@end

@implementation GA_StreamClient

+(GA_StreamClient *)initWithPlayUrl:(NSString *)url
                           delegate:(id<GA_StreamClientDelegate>)delegate{
    
    GA_StreamClient *streamClient = [GA_StreamClient new];
    streamClient.playUrl = url;
    streamClient.delegate = delegate;
    streamClient.rtspHandlerPort =INVALID_PORT;
    
    int result = StreamClient_InitLib();
    if (result!=HANLDER_SUCCESS) {
        NSLog(@"**********GA_StreamClient 初始化错误");
    }
    
    return streamClient;
}


-(void)initStreamClient{
    
    if (self.rtspHandlerPort!=INVALID_PORT) {
        return;
    }
    
    self.rtspHandlerPort = StreamClient_CreateSession();
    int result=0;
    result = StreamClient_SetDataCallBack(self.rtspHandlerPort,
                                          &GA_StreamClient_RealPlay_RTSPDataCallback,
                                          (__bridge void *)self);
    
    
    result = StreamClient_SetMsgCallBack(self.rtspHandlerPort,
                                         &GA_StreamClient_RealPlay_RTSPMsgCallback,
                                         (__bridge void *)self);
    
    //过期时间30秒
    result = StreamClient_SetRtspTimeout(self.rtspHandlerPort, 15);
    
    StreamClient_EnableLog(NO);
}




-(NSError *)startGetRealPlayStream{
    
    [self stopGetStream];
    [self initStreamClient];
    self.beginTime = nil;
    self.endTime = nil;
    
    int result = 0;
    

    
    result = StreamClient_Start(self.rtspHandlerPort,
                                NULL,
                                (char*)[self.playUrl UTF8String],
                                (char*)[@"iOS" UTF8String],
                                RTPRTSP_TRANSMODE,
                                (char*)[@"admin" UTF8String],
                                (char*)[@"ajEcM3C7Snal" UTF8String]);
    
    if (result==HANLDER_SUCCESS) {
        return nil;
    }
    NSError *error = [self getErrorWithCode:result];
    return error;
}


-(NSError *)startGetPlayBackStream:(NSDate *)beginTime to:(NSDate *)endTime{
    
    if (![beginTime isKindOfClass:[NSDate class]]) {
        NSError *error = [self getError:@"beginTime不是日期类型" code:500];
        return error;
    }
    if (![endTime isKindOfClass:[NSDate class]]) {
        NSError *error = [self getError:@"endTime不是日期类型" code:500];
        return error;
    }
    
    
    [self stopGetStream];
    [self initStreamClient];
    
    self.beginTime = beginTime;
    self.endTime = endTime;
    
    ABS_TIME tempBeginABSTime =  [self toABSTime:beginTime];
    ABS_TIME tempEndABSTime = [self toABSTime:endTime];
    
    int result = 0;
    NSDate *beginDate = [NSDate new];
    result = StreamClient_PlayBackByTime(self.rtspHandlerPort,
                                         NULL,
                                         (char*)[self.playUrl UTF8String],
                                         (char*)[@"iOS" UTF8String],
                                         RTPRTSP_TRANSMODE,
                                         (char*)[@"admin" UTF8String],
                                         (char*)[@"og/hsY0=" UTF8String],
                                         &tempBeginABSTime,
                                         &tempEndABSTime);
    NSDate *endDate = [NSDate new];
    
    NSLog(@"beginDate=%@endDate=%@",beginDate,endDate);
    
    if (result==HANLDER_SUCCESS) {
        return nil;
    }
    NSError *error = [self getErrorWithCode:result];
    return error;
}

-(NSError *)seekPlayback:(NSDate *)offsetTime{
    ABS_TIME tempBeginABSTime   = [self toABSTime:offsetTime];
    ABS_TIME tempEndABSTime     = [self toABSTime:self.endTime];

    int result = 0;
    result = StreamClient_Pause(self.rtspHandlerPort);
    result = StreamClient_RandomPlayByAbs(self.rtspHandlerPort,
                                          &tempBeginABSTime,
                                          &tempEndABSTime);
    result = StreamClient_Resume(self.rtspHandlerPort);

    if (result==HANLDER_SUCCESS) {
        return nil;
    }
    //seek失败之后重新开始取流
    [self startGetPlayBackStream:self.beginTime to:self.endTime];
    return nil;
}


-(NSError *)pauseGetStream{
    int result = 0;
    if (self.rtspHandlerPort!=INVALID_PORT) {
        
        result = StreamClient_Pause(self.rtspHandlerPort);
        if (result==HANLDER_SUCCESS) {
            return nil;
        }
        if (result==STREAM_CLIENT_RTSP_STATE_INVALID) {
            return nil;
        }
        if (result==STREAM_CLIENT_RECV_PAUSE_TIMEOUT) {
            return nil;
        }
    }
 
    NSError *error = [self getErrorWithCode:result];
    return error;
}

-(NSError *)resumeGetStream{
    int result = 0;
    if (self.rtspHandlerPort!=INVALID_PORT) {
        result = StreamClient_Resume(self.rtspHandlerPort);
        if (result==HANLDER_SUCCESS) {
            return nil;
        }
    }
    if (result==STREAM_CLIENT_RECV_PLAY_TIMEOUT) {
        [self startGetPlayBackStream:self.beginTime
                                  to:self.endTime];
        return nil;

    }
    if (result==STREAM_CLIENT_SEND_PLAY_FAIL) {
        [self startGetPlayBackStream:self.beginTime
                                  to:self.endTime];
        return nil;
    }
    
    NSError *error = [self getErrorWithCode:result];
    return error;
}


-(void)stopGetStream{
    if (self.rtspHandlerPort!=INVALID_PORT) {
        int ret = 0;
        ret = StreamClient_SetDataCallBack(self.rtspHandlerPort,
                                              NULL,
                                              NULL);
        
        ret = StreamClient_SetMsgCallBack(self.rtspHandlerPort,
                                             NULL,
                                             NULL);
        
        ret = StreamClient_Stop(self.rtspHandlerPort);
        if (ret!=0) {
            NSLog(@"StreamClient_Stop 失败");
        }
        ret = StreamClient_DestroySession(self.rtspHandlerPort);
        if (ret!=0) {
            NSLog(@"StreamClient_DestroySession 失败");
        }
    }
    self.rtspHandlerPort = INVALID_PORT;
}

-(void)destoryStreamClient{
    if (self.rtspHandlerPort!=INVALID_PORT) {
        BOOL ret = NO;
        ret = StreamClient_Stop(self.rtspHandlerPort);
        ret = StreamClient_DestroySession(self.rtspHandlerPort);
        StreamClient_FiniLib();
    }
    self.rtspHandlerPort = INVALID_PORT;
}

-(NSString *)getLastErrorDescribe{
    return nil;
}


-(ABS_TIME)toABSTime:(NSDate *)date{
    NSInteger year;
    NSInteger monthn;
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    NSInteger seconde;
    
    [date getYear:&year
            month:&monthn
              day:&day
             hour:&hour
           minute:&minute
           second:&seconde];
    
    ABS_TIME absTime = {(unsigned int)year,(unsigned int)monthn,(unsigned int)day,(unsigned int)hour,(unsigned int)minute,(unsigned int)seconde};
    return absTime;
}


-(NSError *)getError:(NSString *)method code:(NSInteger) code{
    NSError *error = [NSError errorWithDomain:@"HIKPlayerSDK_____GA_StreamClient" code:code userInfo:@{NSLocalizedDescriptionKey:method}];
    return error;
}

- (NSError *)getErrorWithCode:(signed int)code {
    
    NSString *localizdeDescription = [self localizedDescriptionWithCode:code];
    NSError *error = [NSError errorWithDomain:@"HIKPlayerSDK" code:code userInfo:@{NSLocalizedDescriptionKey:localizdeDescription}];
    return error;
}

- (NSString *)localizedDescriptionWithCode:(signed int)code {
    
    switch (code) {
        case -3:
            return @"流媒体客户端会话已经用尽";
            break;
        case -2:
            return @"流媒体客户端未初始化";
            break;
        case 1:
            return @"会话无效";
            break;
        case 2:
            return @"超出流媒体用户个数超过最大";
            break;
        case 3:
            return @"设备不在线或网络连接超时";
            break;
        case 4:
            return @"设备掉线";
            break;
        case 5:
            return @"设备超过最大连接数";
            break;
        case 6:
            return @"获取数据失败";
            break;
        case 7:
            return @"获取数据超时";
            break;
        case 8:
            return @"发送数据失败";
            break;
        case 9:
            return @"传输方式无效";
            break;
        case 10:
            return @"创建SOCKET失败";
            break;
        case 11:
            return @"设置SOCKET失败";
            break;
        case 12:
            return @"绑定SOCKET失败";
            break;
        case 13:
            return @"监听SOCKET失败";
            break;
        case 14:
            return @"URL格式错误";
            break;
        case 15:
            return @"RTSP状态无效";
            break;
        case 16:
            return @"RTSP回应错误";
            break;
        case 17:
            return @"RTSP返回状态失败，不等于200或302";
            break;
        case 18:
            return @"解析SDP失败";
            break;
        case 19:
            return @"解析RTSP信令失败";
            break;
        case 20:
            return @"解析SDP时，未解析到traceID";
            break;
        case 21:
            return @"发送describe信令失败";
            break;
        case 22:
            return @"发送setup信令失败";
            break;
        case 23:
            return @"发送play信令失败";
            break;
        case 24:
            return @"发送pause信令失败";
            break;
        case 25:
            return @"发送teardown信令失败";
            break;
        case 26:
            return @"接收describe超时";
            break;
        case 27:
            return @"接收setup超时";
            break;
        case 28:
            return @"接收play超时";
            break;
        case 29:
            return @"接收pause超时";
            break;
        case 30:
            return @"接收teardown超时";
            break;
        case 31:
            return @"describe响应错误";
            break;
        case 32:
            return @"setup响应错误";
            break;
        case 33:
            return @"play响应错误";
            break;
        case 34:
            return @"pause响应错误";
            break;
        case 35:
            return @"teardown响应错误";
            break;
        case 36:
            return @"重定向失败";
            break;
        case 37:
            return @"从RTSP的setup信令解析服务器端口失败";
            break;
        case 38:
            return @"创建UDP异步网络连接失败";
            break;
        case 39:
            return @"打开UDP异步网络连接失败";
            break;
        case 40:
            return @"UDP投递异步接收请求失败";
            break;
        case 41:
            return @"相对时间回放时间错误";
            break;
        case 42:
            return @"绝对时间回放时间错误";
            break;
        case 43:
            return @"消息回调设置错误";
            break;
        case 44:
            return @"发送云台控制信令失败";
            break;
        case 45:
            return @"发送强制I帧信令失败";
            break;
        case 46:
            return @"发送获取视频参数信令失败";
            break;
        case 47:
            return @"发送设置视频参数信令失败";
            break;
        case 48:
            return @"接收云台控制信令超时";
            break;
        case 49:
            return @"接收强制I帧信令超时";
            break;
        case 50:
            return @"接收获取视频参数信令超时";
            break;
        case 51:
            return @"接收设置视频参数信令超时";
            break;
        case 52:
            return @"函数未实现";
            break;
        case 53:
            return @"配置RTSP会话时，某参数无效";
            break;
        case 54:
            return @"函数参数无效";
            break;
        case 55:
            return @"会话指针无效";
            break;
        case 56:
            return @"内存不足或申请内存失败";
            break;
        case 57:
            return @"发送设置参数信令失败";
            break;
        case 58:
            return @"接收设置参数信令超时";
            break;
        case 59:
            return @"发送心跳信令失败";
            break;
        case 60:
            return @"接收心跳信令超时";
            break;
        case 61:
            return @"推流传输方式无效";
            break;
        case 62:
            return @"权限不足";
            break;
        case 63:
            return @"帧分析失败";
            break;
        case 64:
            return @"信令解析出错";
            break;
        case 65:
            return @"集群中无vtdu存在";
            break;
        case 66:
            return @"集群超载时，权限不足";
            break;
        case 67:
            return @"权限限制";
            break;
        case 68:
            return @"服务器内部错误";
            break;
        case 69:
            return @"推流方式下流媒体监听端口";
            break;
        case 70:
            return @"用户密码错误";
            break;
        case 71:
            return @"流媒体客户端内部错误";
            break;
        case 72:
            return @"不带鉴权信息的请求取流失败";
            break;
        case 73:
            return @"安全认证下传入的token值无效";
            break;
        case 74:
            return @"buffer长度不够";
            break;
            
        // 消息回调错误定义(流媒体客户端产生)
        case 4001:
            return @"发送心跳失败";
            break;
        case 4002:
            return @"心跳超时";
            break;
        case 4003:
            return @"不支持转封装成PS码流标识，消息数据回调中使用";
            break;
        case 4004:
            return @"码流已经是PS流，不再转封装，直接回调原始码流，消息数据回调中使用";
            break;
        case 4005:
            return @"转封装开启失败";
            break;
        
        // 消息回调错误定义(流媒体服务器产生)
        case 8001:
            return @"因权限不足，被踢掉";
            break;
        case 8002:
            return @"回放定位失败";
            break;
        case 8501:
            return @"错误";
            break;
        case 8502:
            return @"请求的参数错误";
            break;
        case 8503:
            return @"用户名密码错误";
            break;
        case 8504:
            return @"设备不在线，或连接超时";
            break;
        case 8601:
            return @"取流超时";
            break;
        case 8602:
            return @"没有码流头";
            break;
        case 8603:
            return @"vag取流交互失败";
            break;
        case 8604:
            return @"解析url失败";
            break;
        case 8605:
            return @"登录VAG失败";
            break;
        case 8606:
            return @"查询VAG资源";
            break;
        case 8607:
            return @"海康设备取流";
            break;
        case 8608:
            return @"大华设备取流";
            break;
        case 8609:
            return @"主动设备收流连接开启失败";
            break;
        case 9000:
            return @"VTM错误";
            break;
        default:
            return @"未知错误";
            break;
    }
}


@end
