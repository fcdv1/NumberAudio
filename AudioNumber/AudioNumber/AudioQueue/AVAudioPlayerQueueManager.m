//
//  AVAudioPlayerQueueManager.m
//  AVAudioPlayerQueue
//
//  Created by CIA on 14/06/2018.
//  Copyright © 2018 CIA. All rights reserved.
//

#import "AVAudioPlayerQueueManager.h"
@import AVFoundation;

@interface AudioPlayerQueueItem:NSObject
@property (nonatomic, strong) NSArray <NSString *> *audioFiles;
@property (nonatomic, strong) NSArray <NSData *> *audioDatas;
@property (nonatomic, strong) NSString *taskID;
@property (nonatomic, strong) AudioPlayBackCallBack beginPlayCallBack;
@property (nonatomic, strong) AudioPlayBackCallBack endPlayCallBack;
@property (nonatomic, assign) NSInteger nowPlayingIndex;

@end

@implementation AudioPlayerQueueItem
@end

@interface AVAudioPlayerQueueManager()<AVAudioPlayerDelegate>
@property (nonatomic, strong) NSMutableArray <AudioPlayerQueueItem *>*audioItems;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) AudioPlayerQueueItem *nowPlayingItem;
@end

@implementation AVAudioPlayerQueueManager

+(instancetype) sharedInstance{
    static dispatch_once_t onectToken;
    static AVAudioPlayerQueueManager *manager = nil;
    dispatch_once(&onectToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioItems = [NSMutableArray new];
    }
    return self;
}

-(void) enqueueBundleAudioFiles:(NSArray <NSString *> *)bundleAudioFileNames withTaskIdentifer:(NSString *)taskIdentifer beginPlayCallBack:(AudioPlayBackCallBack)beginPlayCallBack endPlayCallBack:(AudioPlayBackCallBack)endPlayCallBack{
    AudioPlayerQueueItem *item = [AudioPlayerQueueItem new];
    item.taskID = taskIdentifer;
    item.audioFiles = bundleAudioFileNames;
    item.beginPlayCallBack = beginPlayCallBack;
    item.endPlayCallBack = endPlayCallBack;
    [self enqueueTask:item];
}

-(void) enqueueAudioDatas:(NSArray <NSData *> *)audioDatas withTaskIdentifer:(NSString *)taskIdentifer beginPlayCallBack:(AudioPlayBackCallBack)beginPlayCallBack endPlayCallBack:(AudioPlayBackCallBack)endPlayCallBack{
    AudioPlayerQueueItem *item = [AudioPlayerQueueItem new];
    item.taskID = taskIdentifer;
    item.audioDatas = audioDatas;
    item.beginPlayCallBack = beginPlayCallBack;
    item.endPlayCallBack = endPlayCallBack;
    [self enqueueTask:item];
}

-(void) cancelAudioPlayBackWithTaskID:(NSString *)taskID{
    BOOL needNext = NO;
    if ([self.nowPlayingItem.taskID isEqualToString:taskID]) {
        [self.audioPlayer pause];
        if (self.nowPlayingItem.endPlayCallBack) {
            self.nowPlayingItem.endPlayCallBack(self.nowPlayingItem.taskID);
        }
        needNext = YES;
    }
    NSMutableArray *removedItems = [NSMutableArray new];
    for (AudioPlayerQueueItem *item in self.audioItems) {
        if ([item.taskID isEqualToString:taskID]) {
            [removedItems addObject:item];
        }
    }
    [self.audioItems removeObjectsInArray:removedItems];
    if (needNext) {
        [self playNextItem];
    }
}

-(void) cancelAllTask{
    [self.audioItems removeAllObjects];
    if (self.nowPlayingItem) {
        [self.audioPlayer pause];
        if (self.nowPlayingItem.endPlayCallBack) {
            self.nowPlayingItem.endPlayCallBack(self.nowPlayingItem.taskID);
        }
    }
    self.audioPlayer = nil;
    self.nowPlayingItem = nil;
}

#pragma mark - private
-(void) enqueueTask:(AudioPlayerQueueItem *)task{
    [self.audioItems addObject:task];
    if (self.nowPlayingItem == nil) {
        [self playNextItem];
    }
}
-(void) playNextItem{
    AudioPlayerQueueItem *item = [self.audioItems firstObject];
    if (item == nil) {
        self.audioPlayer = nil;
        self.nowPlayingItem = nil;
        return;
    }
    self.nowPlayingItem = item;
    [self.audioItems removeObjectAtIndex:0];
    [self beginPlayItem:item];
}
-(void)beginPlayItem:(AudioPlayerQueueItem *)item{
    if (item.beginPlayCallBack) {
        item.beginPlayCallBack(item.taskID);
    }
    item.nowPlayingIndex = 0;
    [self playItemNextFile:item];
}
-(void) playItemNextFile:(AudioPlayerQueueItem *)item{
    NSData *audioData = nil;
    if (item.audioDatas != nil) {
        //采用data播放
        if (item.nowPlayingIndex < item.audioDatas.count) {
            audioData = item.audioDatas[item.nowPlayingIndex];
            item.nowPlayingIndex += 1;
        } else {
            //没有音频数据了
            [self allItemFilePlayFinished:item];
            return;
        }
    } else {
        //采用文件名播放
        if (item.nowPlayingIndex < item.audioFiles.count) {
            NSString *dataPath = [[NSBundle mainBundle] pathForResource:item.audioFiles[item.nowPlayingIndex] ofType:nil];
            audioData = [NSData dataWithContentsOfFile:dataPath];
            item.nowPlayingIndex += 1;
        } else {
            //没有音频数据了
            [self allItemFilePlayFinished:item];
            return;
        }
    }
    if (audioData) {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        if (player == nil) {
            [self playItemNextFile:item];
        } else {
            self.audioPlayer = player;
            self.audioPlayer.delegate = self;
            [self.audioPlayer play];
        }
    } else {
        [self playItemNextFile:item];
    }
}
-(void) allItemFilePlayFinished:(AudioPlayerQueueItem *)item{
    if (item.endPlayCallBack) {
        item.endPlayCallBack(item.taskID);
    }
    self.nowPlayingItem = nil;
    [self playNextItem];
}

#pragma mark - AVAudioPlayer delegate
-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.nowPlayingItem) {
        [self playItemNextFile:self.nowPlayingItem];
    }
}

@end
