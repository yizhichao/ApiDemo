//
//  GA_StreamClient.h
//  Pods
//
//  Created by wangyong14 on 2017/11/11.
//

#import <Foundation/Foundation.h>

@class GA_StreamClient;

@protocol GA_StreamClientDelegate <NSObject>

-(void)GA_StreamClient:(GA_StreamClient *) client
              dataType:(NSInteger) dataType
                  data:(char*) data
                   len:(NSInteger) len
                 error:(NSError *)error;

@end



@interface GA_StreamClient : NSObject

+ (GA_StreamClient *)initWithPlayUrl:(NSString *)url
                            delegate:(id<GA_StreamClientDelegate>) delegate;

@property(nonatomic,weak) id<GA_StreamClientDelegate> delegate;;

- (NSError *)startGetRealPlayStream;

- (NSError *)startGetPlayBackStream:(NSDate *)from
                                 to:(NSDate *) to;

- (NSError *)seekPlayback:(NSDate *)offsetTime;

- (NSError *)pauseGetStream;

- (NSError *)resumeGetStream;

- (NSError *)stopGetStream;

- (void)destoryStreamClient;

- (NSString *)getLastErrorDescribe;


@end
