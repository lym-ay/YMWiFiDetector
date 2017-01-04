//
//  YMWiFiDetector.m
//  YMWiFiDetector
//
//  Created by yanminli on 2016/12/30.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import "YMWiFiDetector.h"
#import "DLNWiFiDetector.h"

@interface YMWiFiDetector()<DLNWiFiDetectorDelegate>
@property (nonatomic, strong) DLNWiFiDetector *detector;
@end

@implementation YMWiFiDetector

static YMWiFiDetector* instance = nil;

+(YMWiFiDetector*)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMWiFiDetector alloc] init];
    });
    return instance;
}

-(id)init{
    if (self = [super init]) {
        self.detector = [[DLNWiFiDetector alloc] init];
        self.detector.delegate = self;
        _availableIP = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)startScanning{
    [_detector startScanning];
}



#pragma mark - DLNWiFiDetectorDelegate
- (void)wifiDetectorSearchOutIP:(NSString *)ip withHost:(NSString *)host {
    NSLog(@"ip is %@",ip);
    if (ip) {
        [_availableIP addObject:ip];
    }
}

- (void)wifiDetectorSearchFinished {
    [self.delegate wifiDetectorSearchFinished];
    
}
@end
