//
//  SocketManager.m
//  YMSocketDemo
//
//  Created by yanminli on 2016/12/30.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import "SocketManager.h"

@interface SocketManager()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) dispatch_queue_t socketQueue;         // 发数据的串行队列
@property (strong, nonatomic) dispatch_queue_t receiveQueue;        // 收数据处理的串行队列
@property (strong, nonatomic) NSString *ip;
@property (assign, nonatomic) UInt16 port;
@property (assign, nonatomic) BOOL isConnecting;

@end



@implementation SocketManager

static SocketManager *instance = nil;
static NSTimeInterval TimeOut = -1;       // 超时时间, 超时会关闭 socket

+ (SocketManager *)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SocketManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.isConnecting = false;
        [self resetSocket];
    }
    return self;
}

- (dispatch_queue_t)socketQueue {
    if (_socketQueue == nil) {
        _socketQueue = dispatch_queue_create("com.sendSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _socketQueue;
}

- (dispatch_queue_t)receiveQueue {
    if (_receiveQueue == nil) {
        _receiveQueue = dispatch_queue_create("com.receiveSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _receiveQueue;
}

- (void)resetSocket {
    [self disConnect];
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
    self.socket.IPv6Enabled = true;
    self.socket.IPv4Enabled = true;
    self.socket.IPv4PreferredOverIPv6 = false;     // 4 优先
}

 
- (void)connectWithIp:(NSString *)ip port:(UInt16)port {
    self.ip = ip;
    self.port = port;
    
    [self resetSocket];
    NSError *error = nil;
    [self.socket connectToHost:self.ip onPort:self.port withTimeout:1000 error:&error];   // 填写 地址，端口进行连接
    if (error != nil) {
        NSLog(@"连接错误：%@", error);
    }
}

- (void)disConnect {
    [self.socket disconnect];
    self.socket = nil;
    self.socketQueue = nil;
}

- (void)send:(NSData *)data {
    NSLog(@"socket send 发送数据");
    // socket 的操作要在 self.socketQueue（socket 的代理队列）中才有效，不允许其他线程来设置本 socket
    dispatch_async(self.socketQueue, ^{
        if (self.socket == nil || self.socket.isDisconnected) {
                [self connectWithIp:self.ip port:self.port];     
            
        }
        [self.socket readDataWithTimeout:TimeOut tag:100];           // 每次都要设置接收数据的时间, tag
        [self.socket writeData:data withTimeout:TimeOut tag:100];    // 再发送
    });
}

- (BOOL)status {
    if (self.socket != nil && self.socket.isConnected) {
        return true;
    }
    return false;
}

// 代理方法
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //NSLog(@"连接成功:%@, %d", host, port);
    dispatch_async(self.receiveQueue, ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didConnect:port:)]) {
            [self.delegate socket:sock didConnect:host port:port];
        }
        
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    //NSLog(@"断开连接socketDidDisconnect");
    dispatch_async(self.receiveQueue, ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidDisconnect:)]) {
            [self.delegate socketDidDisconnect:sock];
        }
        self.socket = nil;
        self.socketQueue = nil;
    });
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    dispatch_async(self.receiveQueue, ^{
        // 防止 didReadData 被阻塞，用个其他队列里的线程去回调 block
        if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReadData:)]) {
            [self.delegate socket:sock didReadData:data];
        }
    });
    [self.socket readDataWithTimeout:TimeOut tag:100];       // 设置下次接收数据的时间, tag
}



@end

