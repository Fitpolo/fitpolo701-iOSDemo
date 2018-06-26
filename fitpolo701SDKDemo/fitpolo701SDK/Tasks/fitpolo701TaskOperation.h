//
//  fitpolo701TaskOperation.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo701TaskIDDefines.h"

/**
 发送命令回调
 */
typedef void(^communicationCommandBlock)(void);

/**
 任务完成回调
 
 @param error 是否产生了超时错误
 @param operationID 当前任务ID
 @param returnData 返回的数据
 */
typedef void(^communicationCompleteBlock)(NSError *error, fitpolo701TaskOperationID operationID, id returnData);

extern NSString *const fitpolo701AdditionalInformation;
extern NSString *const fitpolo701DataInformation;
extern NSString *const fitpolo701DataStatusLev;

@interface fitpolo701TaskOperation : NSOperation

/**
 初始化通信线程

 @param operationID 当前线程的任务ID
 @param resetNum 是否需要根据外设返回的数据总条数来修改任务需要接受的数据总条数，YES需要，NO不需要
 @param commandBlock 发送命令回调
 @param completeBlock 数据通信完成回调
 @return operation
 */
- (instancetype)initOperationWithID:(fitpolo701TaskOperationID)operationID
                           resetNum:(BOOL)resetNum
                       commandBlock:(communicationCommandBlock)commandBlock
                      completeBlock:(communicationCompleteBlock)completeBlock;

@end
