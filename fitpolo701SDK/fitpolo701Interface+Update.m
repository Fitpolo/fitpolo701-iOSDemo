//
//  fitpolo701Interface+Update.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701Interface+Update.h"
#import "fitpolo701PeripheralManager.h"
#import "fitpolo701Parser.h"
#import "fitpolo701RegularsDefine.h"
#import "fitpolo701CentralManager.h"

@implementation fitpolo701Interface (Update)

/**
 手环开启升级固件
 
 @param crcData 本地升级的校验码，两个字节，将本地的固件做crc16得出来的
 @param packageSize 本次升级的固件大小，4个字节
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralStartUpdateWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                             failedBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (!fitpolo701ValidData(crcData) || !fitpolo701ValidData(packageSize)) {
        fitpolo701ParamsError(failedBlock);
        return;
    }
    NSData *headerData = [fitpolo701Parser stringToData:@"28"];
    NSMutableData *commandData = [NSMutableData dataWithData:headerData];
    [commandData appendData:crcData];
    [commandData appendData:packageSize];
    NSString *commandString = [fitpolo701Parser hexStringFromData:commandData];
    [[fitpolo701CentralManager sharedInstance].peripheralManager addTaskWithTaskID:fitpolo701StartUpdateOperation
                                                                          resetNum:NO
                                                                       commandData:commandString
                                                                      successBlock:successBlock
                                                                      failureBlock:failedBlock];
}

@end
