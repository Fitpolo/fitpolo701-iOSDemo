//
//  fitpolo701CentralManager.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo701Defines.h"
#import "fitpolo701TaskOperation.h"

extern NSString *const fitpolo701PeripheralConnectStateChanged;
////外设固件升级结果通知,由于升级固件采用的是无应答定时器发送数据包，所以当产生升级结果的时候，需要靠这个通知来结束升级过程
extern NSString *const fitpolo701PeripheralUpdateResultNotification;

typedef NS_ENUM(NSInteger, fitpolo701ConnectStatus) {
    fitpolo701ConnectStatusUnknow,                                           //未知状态
    fitpolo701ConnectStatusConnecting,                                       //正在连接
    fitpolo701ConnectStatusConnected,                                        //连接成功
    fitpolo701ConnectStatusConnectedFailed,                                  //连接失败
    fitpolo701ConnectStatusDisconnect,                                       //连接断开
};

typedef NS_ENUM(NSInteger, fitpolo701CentralManagerState) {
    fitpolo701CentralManagerStateEnable,                           //可用状态
    fitpolo701CentralManagerStateUnable,                           //不可用
};

/**
 中心设备连接外设失败的Block
 
 @param error 错误信息
 */
typedef void(^fitpolo701ConnectPeripheralFailedBlock)(NSError *error);

/**
 设备连接成功回调
 
 @param connectedPeripheral 当前已经连接的设备
 @param macAddress 已经连接的设备的mac地址
 (只有connectPeripheralWithIdentifier:
 connectType:
 peripheralType:
 connectSuccessBlock:
 connectFailBlock:方法连接的设备才会有值)
 @param peripheralName 已经连接的设备的名称
 (只有connectPeripheralWithIdentifier:
 connectType:
 peripheralType:
 connectSuccessBlock:
 connectFailBlock:方法连接的设备才会有值)
 */
typedef void(^fitpolo701ConnectPeripheralSuccessBlock)(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName);

/**
 数据通信成功
 
 @param returnData 返回的Json数据
 */
typedef void(^fitpolo701CommunicationSuccessBlock)(id returnData);

/**
 数据通信失败
 
 @param error 失败原因
 */
typedef void(^fitpolo701CommunicationFailedBlock)(NSError *error);

@class fitpolo701CentralManager;
@protocol fitpolo701ScanPeripheralDelegate <NSObject>
/**
 中心开始扫描
 
 @param centralManager 中心
 */
- (void)fitpolo701CentralStartScan:(fitpolo701CentralManager *)centralManager;
/**
 扫描到新的设备
 
 @param peripheral 扫描到的设备
 @param macAddress 设备的mac地址
 @param peripheralName 设备的名称
 @param centralManager 中心
 */
- (void)fitpolo701CentralScanningNewPeripheral:(CBPeripheral *)peripheral
                                    macAddress:(NSString *)macAddress
                                peripheralName:(NSString *)peripheralName
                                centralManager:(fitpolo701CentralManager *)centralManager;
/**
 中心停止扫描
 
 @param centralManager 中心
 */
- (void)fitpolo701CentralStopScan:(fitpolo701CentralManager *)centralManager;

@end

@protocol fitpolo701CentralManagerStateDelegate <NSObject>

/**
 中心蓝牙状态改变
 
 @param managerState 中心蓝牙状态
 @param manager 中心
 */
- (void)fitpolo701CentralStateChanged:(fitpolo701CentralManagerState)managerState manager:(fitpolo701CentralManager *)manager;

/**
 中心与外设连接状态改变
 
 @param connectState 外设连接状态
 @param manager 中心
 */
- (void)fitpolo701PeripheralConnectStateChanged:(fitpolo701ConnectStatus)connectState manager:(fitpolo701CentralManager *)manager;

@end

@interface fitpolo701CentralManager : NSObject

@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

/**
 当前外设连接状态
 */
@property (nonatomic, assign, readonly)fitpolo701ConnectStatus connectStatus;

/**
 当前中心蓝牙状态
 */
@property (nonatomic, assign, readonly)fitpolo701CentralManagerState centralStatus;

@property (nonatomic, strong, readonly)CBPeripheral *connectedPeripheral;;

/**
 扫描回调
 */
@property (nonatomic, weak)id <fitpolo701ScanPeripheralDelegate>scanDelegate;

/**
 中心状态代理
 */
@property (nonatomic, weak)id <fitpolo701CentralManagerStateDelegate>managerStateDelegate;

+ (fitpolo701CentralManager *)sharedInstance;

/**
 销毁单例
 */
+ (void)singletonDestroyed;

/**
 开始扫描701设备
 */
- (void)startScanPeripheral;

/**
 停止扫描
 */
- (void)stopScan;

/**
 根据标识符和连接方式来连接指定的外设
 
 @param identifier 要连接外设的标识符,目前支持设备UUID、设备mac地址(xx-xx-xx-xx-xx-xx)、设备mac地址低四位(xx-xx)三种连接方式。
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                    connectSuccessBlock:(fitpolo701ConnectPeripheralSuccessBlock)successBlock
                       connectFailBlock:(fitpolo701ConnectPeripheralFailedBlock)failedBlock;

/**
 连接指定设备
 
 @param peripheral 目标设备
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
      connectSuccessBlock:(fitpolo701ConnectPeripheralSuccessBlock)connectSuccessBlock
       connectFailedBlock:(fitpolo701ConnectPeripheralFailedBlock)connectFailedBlock;

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral;

#pragma mark - task
- (void)writeDataToLog:(NSString *)commandData operation:(fitpolo701TaskOperationID)operationID;

- (BOOL)sendUpdateData:(NSData *)updateData;

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
