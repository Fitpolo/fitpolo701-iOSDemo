//
//  fitpolo701Interface+RequestData.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701Interface+RequestData.h"
#import "fitpolo701Defines.h"
#import "fitpolo701Parser.h"

@implementation fitpolo701Interface (RequestData)

#pragma mark - 请求类指令

/**
 请求设备电量
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralBatteryWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                   failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    [self requestPeripheralMemoryDataWithSucBlock:^(id returnData) {
        NSString *battery = returnData[@"result"][@"battery"];
        if (!fitpolo701ValidStr(battery)) {
            [fitpolo701Parser operationRequestDataErrorBlock:failedBlock];
            return ;
        }
        NSDictionary *resultDic = @{
                                    @"code":@"1",
                                    @"msg":@"success",
                                    @"result":@{
                                            @"battery":battery,
                                            }
                                    };
        fitpolo701_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    } failBlock:failedBlock];
}

/**
 请求硬件参数
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralHardwareParametersWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                              failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1622";
    [self addTaskWithID:fitpolo701GetHardwareParametersOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

/**
 请求手环固件版本号
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralFirwareVersionWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                          failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1606";
    [self addTaskWithID:fitpolo701GetFirmwareVersionOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

/**
 请求内部版本号
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralInternalVersionWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                           failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1609";
    [self addTaskWithID:fitpolo701GetInternalVersionOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

/**
 请求当前设备ancs选项
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralAncsOptionsWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                       failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1611";
    [self addTaskWithID:fitpolo701GetANCSOptionsOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

/**
 请求计步数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralStepDataWithDate:(NSDate *)date
                                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    [self requestPeripheralDataWithDate:date
                               dataType:fitpolo701RequestStepDataWithTimeStamp
                               sucBlock:successBlock
                              failBlock:failedBlock];
}

/**
 请求睡眠数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有睡眠数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralSleepDataWithDate:(NSDate *)date
                                  sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                 failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    fitpolo701WS(weakSelf);
    [self requestPeripheralDataWithDate:date dataType:fitpolo701RequestSleepIndexDataWithTimeStamp sucBlock:^(id sleepIndexData) {
        NSArray *indexList = sleepIndexData[@"result"];
        if (!indexList) {
            [fitpolo701Parser operationRequestDataErrorBlock:failedBlock];
            return;
        }
        if (indexList.count == 0) {
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":@[],
                                        };
            fitpolo701_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        [weakSelf requestPeripheralDataWithDate:date dataType:fitpolo701RequestSleepRecordDataWithTimeStamp sucBlock:^(id sleepRecordData) {
            NSArray *recordList = sleepRecordData[@"result"];
            if (!fitpolo701ValidArray(recordList)) {
                [fitpolo701Parser operationRequestDataErrorBlock:failedBlock];
                return;
            }
            NSArray *sleepList = [fitpolo701Parser getSleepDataList:indexList recordList:recordList];
            if (!fitpolo701ValidArray(sleepList)) {
                [fitpolo701Parser operationRequestDataErrorBlock:failedBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":sleepList,
                                        };
            fitpolo701_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
        } failBlock:failedBlock];
    } failBlock:failedBlock];
}

/**
 请求心率数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralHeartRateDataWithDate:(NSDate *)date
                                      sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                     failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    [self requestPeripheralDataWithDate:date
                               dataType:fitpolo701RequestHeartRateDataWithTimeStamp
                               sucBlock:^(id returnData) {
                                   NSArray *dataList = returnData[@"result"];
                                   NSMutableArray *resultList = [NSMutableArray array];
                                   for (NSDictionary *dic in dataList) {
                                       NSArray *heartList = dic[@"heartList"];
                                       if (fitpolo701ValidArray(heartList)) {
                                           [resultList addObjectsFromArray:heartList];
                                       }
                                   }
                                   NSDictionary *resultDic = @{@"msg":@"success",
                                                               @"code":@"1",
                                                               @"result":resultList,
                                                               };
                                   fitpolo701_main_safe(^{
                                       if (successBlock) {
                                           successBlock(resultDic);
                                       }
                                   });
                               }
                              failBlock:failedBlock];
}

/**
 请求闹钟数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralAlarmClockDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                          failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"b001";
    [[fitpolo701CentralManager sharedInstance] addNeedResetNumTaskWithTaskID:fitpolo701GetAlarmClockDataOperation number:2 commandData:commandString successBlock:^(id returnData) {
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *dic in returnData[@"result"]) {
            NSArray *tempList = dic[@"clockList"];
            if (fitpolo701ValidArray(tempList)) {
                [list addObjectsFromArray:tempList];
            }
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":list,
                                    };
        fitpolo701_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    } failureBlock:failedBlock];
}

/**
 获取久坐提醒数据

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralSedentaryRemindDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                               failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"b002";
    [self addTaskWithID:fitpolo701GetSedentaryRemindOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

/**
 请求配置参数

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralConfigurationParametersDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                                       failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"b004";
    [self addTaskWithID:fitpolo701GetConfigurationParametersOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

#pragma mark - Private method
+ (void)addTaskWithID:(fitpolo701TaskOperationID)taskID
        commandString:(NSString *)commandString
             sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    [[fitpolo701CentralManager sharedInstance] addTaskWithTaskID:taskID
                                                        resetNum:NO
                                                     commandData:commandString
                                                    successBlock:successBlock
                                                    failureBlock:failedBlock];
}

/**
 请求设备memory数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralMemoryDataWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1600";
    [self addTaskWithID:fitpolo701GetMemoryDataOperation
          commandString:commandString
               sucBlock:successBlock
              failBlock:failedBlock];
}

/**
 请求数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param dataType 请求数据类型，目前支持计步、睡眠index、睡眠record、心率
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)requestPeripheralDataWithDate:(NSDate *)date
                             dataType:(fitpolo701RequestDataWithTimeStamp)dataType
                             sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                            failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *hexTime = [fitpolo701Parser getTimeStringWithDate:date];
    if (!fitpolo701ValidStr(hexTime)) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    //默认是计步
    NSString *function = @"92";
    fitpolo701TaskOperationID operationID = fitpolo701GetStepDataOperation;
    if (dataType == fitpolo701RequestSleepIndexDataWithTimeStamp) {
        //睡眠index
        function = @"93";
        operationID = fitpolo701GetSleepIndexOperation;
    }else if (dataType == fitpolo701RequestSleepRecordDataWithTimeStamp){
        //睡眠record
        function = @"94";
        operationID = fitpolo701GetSleepRecordOperation;
    }else if (dataType == fitpolo701RequestHeartRateDataWithTimeStamp){
        //心率
        function = @"a8";
        operationID = fitpolo701GetHeartDataOperation;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"2c",hexTime,function];
    [[fitpolo701CentralManager sharedInstance] addNeedPartOfDataTaskWithTaskID:operationID
                                                                   commandData:commandString
                                                                  successBlock:successBlock
                                                                  failureBlock:failedBlock];
}

@end
