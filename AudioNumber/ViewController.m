//
//  ViewController.m
//  AudioNumber
//
//  Created by CIA on 14/06/2018.
//  Copyright © 2018 CIA. All rights reserved.
//

#import "ViewController.h"
#import "AVAudioPlayerQueueManager.h"
@import AVFoundation;
#import "NumberToFiles.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}


- (IBAction)playButtonPressed:(id)sender {
    srand((unsigned int)time(NULL));
    double value = (rand()%1000000000 / 10000.0);
    
    NSArray <NSString *>*englishAudioFiles = [NumberToFiles fileNamesWithFloatValue:value fileType:KFileTypeEnglish];
    [[AVAudioPlayerQueueManager sharedInstance] enqueueBundleAudioFiles:englishAudioFiles withTaskIdentifer:nil beginPlayCallBack:^(NSString *taskID){
        NSLog(@"English:%f",value);
    } endPlayCallBack:nil];
    
    NSArray <NSString *>*chineseAudioFiles = [NumberToFiles fileNamesWithFloatValue:value fileType:KFileTypeCN];
    [[AVAudioPlayerQueueManager sharedInstance] enqueueBundleAudioFiles:chineseAudioFiles withTaskIdentifer:nil beginPlayCallBack:^(NSString *taskID){
        NSLog(@"Chinese:%f",value);
    } endPlayCallBack:nil];
}
- (IBAction)cancelAllButtonPressed:(id)sender {
    [[AVAudioPlayerQueueManager sharedInstance] cancelAllTask];
}


@end
