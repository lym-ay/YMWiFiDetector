//
//  YMWiFiDetector.h
//  YMWiFiDetector
//
//  Created by yanminli on 2016/12/30.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMWiFiDetectorDelegate <NSObject>
@optional
- (void)wifiDetectorSearchFinished;


@end

@interface YMWiFiDetector : NSObject
+(YMWiFiDetector*)instance;
-(void)startScanning;
@property (nonatomic,strong) NSMutableArray *availableIP;
@property (nonatomic,weak) id<YMWiFiDetectorDelegate> delegate;
@end
