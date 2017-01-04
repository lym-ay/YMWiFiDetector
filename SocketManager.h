//
//  SocketManager.h
//  YMSocketDemo
//
//  Created by yanminli on 2016/12/30.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol SocketManagerDelegate <NSObject>

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data;
- (void)socket:(GCDAsyncSocket *)socket didConnect:(NSString *)host port:(uint16_t)port;
- (void)socketDidDisconnect:(GCDAsyncSocket *)socket;

@end

// socket 连接管理类
@interface SocketManager : NSObject

@property (weak, nonatomic) id<SocketManagerDelegate> delegate;

+ (SocketManager *)instance;    // 可以使用单例，也可以 alloc 一个新的临时用

- (void)connectWithIp:(NSString *)ip port:(UInt16)port;
- (void)disConnect;
- (void)send:(NSData *)data;
- (BOOL)status;

@end

