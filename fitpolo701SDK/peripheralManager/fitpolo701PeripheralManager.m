//
//  fitpolo701PeripheralManager.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701PeripheralManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "fitpolo701LogManager.h"
#import "fitpolo701OperationManager.h"
#import "fitpolo701ConstDefines.h"
#import "fitpolo701Parser.h"
#import "fitpolo701RegularsDefine.h"
#import "fitpolo701DataParser.h"

@interface fitpolo701PeripheralManager()<CBPeripheralDelegate>

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, strong)CBCharacteristic *write;

@property (nonatomic, strong)CBCharacteristic *listen;

/**
 数据解析中心
 */
@property (nonatomic, strong)fitpolo701DataParser *dataParser;

/**
 线程管理者
 */
@property (nonatomic, strong)fitpolo701OperationManager *operationManager;

@end

@implementation fitpolo701PeripheralManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"外设销毁");
    [self.operationManager cancelAllOperations];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    for (CBService *service in peripheral.services) {
        //发现服务
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFC1"],
                                                  [CBUUID UUIDWithString:@"FFC2"]]
                                     forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    [self setCharacteristic:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"read data from peripheral error:%@", [error localizedDescription]);
        return;
    }
    NSData *readData = characteristic.value;
    [self.dataParser parseReadData:[fitpolo701Parser hexStringFromData:readData]];
}

#pragma mark - delegate process

- (void)setCharacteristic:(CBService *)service{
    if (!service || ![service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
        return;
    }
    for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC1"]]) {
            self.write = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.listen = characteristic;
        }
    }
    if (!self.peripheral || !self.write || !self.listen) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralConnectedSuccessNotification object:nil userInfo:nil];
}

#pragma mark - Public method
- (void)connectPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    self.peripheral = nil;
    self.peripheral = peripheral;
    self.write = nil;
    self.listen = nil;
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:@"FFC0"]]];
}

- (void)cancelConnect{
    self.peripheral = nil;
    self.write = nil;
    self.listen = nil;
    [self.operationManager cancelAllOperations];
}

- (CBPeripheral *)connectedPeripheral{
    return self.peripheral;
}

#pragma mark - 数据通信处理方法
- (void)sendCommandToPeripheral:(NSString *)commandData{
    if (!self.peripheral || !fitpolo701ValidStr(commandData) || !self.write) {
        return;
    }
    NSData *data = [fitpolo701Parser stringToData:commandData];
    if (!fitpolo701ValidData(data)) {
        return;
    }
    [self.peripheral writeValue:data forCharacteristic:self.write type:CBCharacteristicWriteWithoutResponse];
}

- (void)writeDataToLog:(NSString *)commandData operation:(fitpolo701TaskOperationID)operationID{
    if (!fitpolo701ValidStr(commandData)) {
        return;
    }
    NSString *commandType = [fitpolo701Parser getCommandType:operationID];
    if (!fitpolo701ValidStr(commandType)) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%@:%@",commandType,commandData];
    [fitpolo701LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo701DataSourceAPP];
}

- (BOOL)sendUpdateData:(NSData *)updateData{
    if (!self.write) {
        return NO;
    }
    if (!fitpolo701ValidData(updateData)) {
        return NO;
    }
    [self.peripheral writeValue:updateData forCharacteristic:self.write type:CBCharacteristicWriteWithoutResponse];
    NSString *string = [NSString stringWithFormat:@"%@:%@",@"固件升级数据",[fitpolo701Parser hexStringFromData:updateData]];
    [fitpolo701LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo701DataSourceAPP];
    return YES;
}

- (fitpolo701TaskOperation *)generateOperationWithOperationID:(fitpolo701TaskOperationID)operationID
                                                     resetNum:(BOOL)resetNum
                                                  commandData:(NSString *)commandData
                                                 successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                                 failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    if (![self canSendData]) {
        fitpolo701ConnectError(failureBlock);
        return nil;
    }
    if (!fitpolo701ValidStr(commandData)) {
        fitpolo701ParamsError(failureBlock);
        return nil;
    }
    if (!self.write) {
        fitpolo701CharacteristicError(failureBlock);
        return nil;
    }
    fitpolo701WS(weakSelf);
    fitpolo701TaskOperation *operation = [[fitpolo701TaskOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [weakSelf sendCommandToPeripheral:commandData];
        [weakSelf writeDataToLog:commandData operation:operationID];
    } completeBlock:^(NSError *error, fitpolo701TaskOperationID operationID, id returnData) {
        if (error) {
            fitpolo701_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            fitpolo701RequestPeripheralDataError(failureBlock);
            return ;
        }
        NSString *lev = returnData[fitpolo701DataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[fitpolo701DataInformation];
            if (!fitpolo701ValidArray(dataList)) {
                fitpolo701RequestPeripheralDataError(failureBlock);
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            fitpolo701_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        if (![lev isEqualToString:@"2"]) {
            //
            return;
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[fitpolo701DataInformation],
                                    };
        fitpolo701_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}


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
             failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    
    fitpolo701TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:resetNum
                                                                    commandData:commandData
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    [self.operationManager addOperation:operation];
}

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
                           failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    fitpolo701TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:YES
                                                                    commandData:commandData
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL selNeedPartOfData = sel_registerName("needPartOfData:");
    if ([operation respondsToSelector:selNeedPartOfData]) {
        ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)operation, selNeedPartOfData, @(YES));
    }
    [self.operationManager addOperation:operation];
}

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
                         failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    if (number < 1) {
        return;
    }
    fitpolo701TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:NO
                                                                    commandData:commandData
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    SEL setNum = sel_registerName("setRespondCount:");
    NSString *numberString = [NSString stringWithFormat:@"%ld",(long)number];
    if ([operation respondsToSelector:setNum]) {
        ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)operation, setNum, numberString);
    }
    if (!operation) {
        return;
    }
    [self.operationManager addOperation:operation];
}

#pragma mark - Private method

- (BOOL)canSendData{
    if (!self.peripheral) {
        return NO;
    }
    return (self.peripheral.state == CBPeripheralStateConnected);
}

#pragma mark - setter & getter
- (fitpolo701DataParser *)dataParser{
    if (!_dataParser) {
        _dataParser = [[fitpolo701DataParser alloc] init];
    }
    return _dataParser;
}

- (fitpolo701OperationManager *)operationManager{
    if (!_operationManager) {
        _operationManager = [[fitpolo701OperationManager alloc] init];
    }
    return _operationManager;
}

@end
