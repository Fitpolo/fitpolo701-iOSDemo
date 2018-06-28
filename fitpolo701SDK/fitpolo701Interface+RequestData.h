//
//  fitpolo701Interface+RequestData.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701Interface.h"

@interface fitpolo701Interface (RequestData)

#pragma mark - 请求数据类指令
/**
 请求设备电量
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralBatteryWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                   failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 请求硬件参数
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralHardwareParametersWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                              failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 请求手环固件版本号
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralFirwareVersionWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                          failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 请求内部版本号
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralInternalVersionWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                           failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;

/**
 请求当前设备ancs选项
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralAncsOptionsWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                       failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 请求计步数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralStepDataWithDate:(NSDate *)date
                                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 请求睡眠数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有睡眠数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralSleepDataWithDate:(NSDate *)date
                                  sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                 failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 请求心率数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralHeartRateDataWithDate:(NSDate *)date
                                      sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                     failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;

/**
 请求闹钟数据

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralAlarmClockDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                          failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;

/**
 获取久坐提醒数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralSedentaryRemindDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                               failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;

/**
 请求配置参数
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralConfigurationParametersDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                                       failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;

@end
