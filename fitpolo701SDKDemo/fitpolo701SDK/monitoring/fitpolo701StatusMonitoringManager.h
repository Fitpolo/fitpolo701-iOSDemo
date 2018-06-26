//
//  fitpolo701StatusMonitoringManager.h
//  testSDK
//
//  Created by aa on 2018/3/19.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo701EnumerateDefine.h"
#import "fitpolo701BlockDefine.h"

@interface fitpolo701StatusMonitoringManager : NSObject

/**
 当前中心与外设的连接状态
 */
@property (nonatomic, assign, readonly)fitpolo701ConnectStatus connectStatus;

/**
 中心蓝牙状态
 */
@property (nonatomic, assign, readonly)fitpolo701CentralManagerState centralBluetoothStatus;

/**
 监测当前外设连接状况
 
 @param statusBlock 当前外设连接状态回调
 */
- (void)startMonitoringConnectStatus:(fitpolo701ConnectStatusChangedBlock)statusBlock;

/**
 监测当前中心的蓝牙状态
 
 @param statusBlock 当前中心蓝牙状态回调
 */
- (void)startMonitoringCentralManagerStatus:(fitpolo701CentralStatusChangedBlock)statusBlock;

@end
