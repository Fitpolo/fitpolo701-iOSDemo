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

typedef NS_ENUM(NSInteger, fitpolo701ConnectPeripheralType) {
    fitpolo701ConnectPeripheralWithUUID,                //通过uuid方式连接
    fitpolo701ConnectPeripheralWithMacAddress,          //通过mac地址连接
    fitpolo701ConnectPeripheralWithMacAddressLowFour,   //通过mac地址低四位连接
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

@protocol fitpolo701ScanPeripheralDelegate;
@class fitpolo701PeripheralManager;

@interface fitpolo701CentralManager : NSObject

@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

@property (nonatomic, strong, readonly)fitpolo701PeripheralManager *peripheralManager;

/**
 扫描回调
 */
@property (nonatomic, weak)id <fitpolo701ScanPeripheralDelegate>scanDelegate;

// 外部调用将产生编译错误
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

+ (fitpolo701CentralManager *)sharedInstance;

/**
 销毁单例
 */
+ (void)attempDealloc;

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
 @param connectType 连接方式
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                            connectType:(fitpolo701ConnectPeripheralType)connectType
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

/**
 获取当前外设连接状态

 @return connect status
 */
- (fitpolo701ConnectStatus)getCurrentConnectStatus;

@end

@protocol fitpolo701ScanPeripheralDelegate <NSObject>

@optional
- (void)fitpolo701StartScan;
- (void)fitpolo701ScanNewPeripheral:(NSDictionary *)dic;
- (void)fitpolo701StopScan;

@end
