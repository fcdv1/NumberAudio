//
//  AVAudioPlayerQueueManager.h
//  AVAudioPlayerQueue
//
//  Created by CIA on 14/06/2018.
//  Copyright © 2018 CIA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AudioPlayBackCallBack)(NSString *taskID);

@interface AVAudioPlayerQueueManager : NSObject

+(instancetype) sharedInstance;

//enqueue audio task with local audio file in app bundle
//you just need give the file name
-(void) enqueueBundleAudioFiles:(NSArray <NSString *> *)bundleAudioFileNames withTaskIdentifer:(NSString *)taskIdentifer beginPlayCallBack:(AudioPlayBackCallBack)beginPlayCallBack endPlayCallBack:(AudioPlayBackCallBack)endPlayCallBack;

//enqueue audio task with  audio data
-(void) enqueueAudioDatas:(NSArray <NSData *> *)audioDatas withTaskIdentifer:(NSString *)taskIdentifer beginPlayCallBack:(AudioPlayBackCallBack)beginPlayCallBack endPlayCallBack:(AudioPlayBackCallBack)endPlayCallBack;

//cancel task with task id, if a task is begin,it's finish call back will be called, if a task is not begin, it's begin and finish block
// will not be called
-(void) cancelAudioPlayBackWithTaskID:(NSString *)taskID;

//cancel all task, if a task is begin,it's finish call back will be called, if a task is not begin, it's begin and finish block
// will not be called
-(void) cancelAllTask;

@end
