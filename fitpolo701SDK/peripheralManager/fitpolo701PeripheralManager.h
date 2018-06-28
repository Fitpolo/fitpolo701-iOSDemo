//
//  fitpolo701PeripheralManager.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo701TaskIDDefines.h"
#import "fitpolo701TaskOperation.h"
#import "fitpolo701BlockDefine.h"

@class fitpolo701OperationManager;
@class fitpolo701DataParser;
@interface fitpolo701PeripheralManager : NSObject

/**
 数据解析中心
 */
@property (nonatomic, strong, readonly)fitpolo701DataParser *dataParser;

/**
 线程管理者
 */
@property (nonatomic, strong, readonly)fitpolo701OperationManager *operationManager;

- (void)connectPeripheral:(CBPeripheral *)peripheral;

- (void)cancelConnect;

- (CBPeripheral *)connectedPeripheral;

- (void)writeDataToLog:(NSString *)commandData operation:(fitpolo701TaskOperationID)operationID;

- (BOOL)sendUpdateData:(NSData *)updateData;

- (fitpolo701TaskOperation *)generateOperationWithOperationID:(fitpolo701TaskOperationID)operationID
                                                     resetNum:(BOOL)resetNum
                                                  commandData:(NSString *)commandData
                                                 successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                                 failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock;

/**
 添加一个通信任务(app-->peripheral)到队列
 
 @param operationID 任务ID
 @param resetNum 是否需要由外设返回通信数据总条数
 @param commandData 通信数据
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addTaskWithTaskID:(fitpolo701TaskOperationID)operationID
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
             successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
             failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock;
/**
 添加一个通信任务(app-->peripheral)到队列,当获任务结束只获取到部分数据的时候，返回这部分数据到成功回调
 
 @param operationID 任务ID
 @param commandData 通信数据
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addNeedPartOfDataTaskWithTaskID:(fitpolo701TaskOperationID)operationID
                            commandData:(NSString *)commandData
                           successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                           failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock;

/**
 添加一个通信任务(app-->peripheral)到队列,该任务需要设置本次通信数据条数

 @param operationID 任务ID
 @param number 设置的数据条数
 @param commandData 通信命令
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addNeedResetNumTaskWithTaskID:(fitpolo701TaskOperationID)operationID
                               number:(NSInteger)number
                          commandData:(NSString *)commandData
                         successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                         failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock;
@end


