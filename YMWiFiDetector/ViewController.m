//
//  ViewController.m
//  YMWiFiDetector
//
//  Created by yanminli on 2016/12/30.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import "ViewController.h"
#import "YMWiFiDetector.h"
static int num = 0;

@interface ViewController ()<YMWiFiDetectorDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textIP;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityShow;
@property (weak, nonatomic) IBOutlet UITextField *textField;

 
@property (nonatomic,strong)  YMWiFiDetector *detector;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _detector = [YMWiFiDetector instance];
    _detector.delegate = self;
    _activityShow.hidesWhenStopped = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanIP:(id)sender {
    [_detector startScanning];
    
    [_activityShow startAnimating];
    
    
}

-(void)wifiDetectorSearchFinished{
    [_activityShow stopAnimating];
    NSLog(@"%@", @"finished scan ip");
}
- (IBAction)buttnClick:(id)sender {
    NSString *str = [[NSString alloc] initWithFormat:@"%d",num];
    num++;
    _textField.text = str;
}



@end
