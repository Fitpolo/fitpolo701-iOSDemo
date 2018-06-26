//
//  fitpolo701StatusMonitoringManager.m
//  testSDK
//
//  Created by aa on 2018/3/19.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701StatusMonitoringManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo701ConstDefines.h"
#import "fitpolo701PeripheralManager.h"
#import "fitpolo701CentralManager.h"

@interface fitpolo701StatusMonitoringManager()

/**
 中心外设之间连接状态改变时的回调
 */
@property (nonatomic, copy)fitpolo701ConnectStatusChangedBlock peripheralStatusChangedBlock;

/**
 中心蓝牙状态改变
 */
@property (nonatomic, copy)fitpolo701CentralStatusChangedBlock centralManagerStatusChangedBlock;

/**
 当前中心与外设的连接状态
 */
@property (nonatomic, assign)fitpolo701ConnectStatus connectStatus;

@end

@implementation fitpolo701StatusMonitoringManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"监控中心销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo701StartConnectPeripheralNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo701ConnectSuccessNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo701ConnectFailedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo701DisconnectPeripheralNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo701BluetoothStateChangedNotification
                                                  object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startConnectPeripheral)
                                                     name:fitpolo701StartConnectPeripheralNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralSuccess)
                                                     name:fitpolo701ConnectSuccessNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralFailed)
                                                     name:fitpolo701ConnectFailedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDisconnect)
                                                     name:fitpolo701DisconnectPeripheralNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(centralManagerStateChanged)
                                                     name:fitpolo701BluetoothStateChangedNotification
                                                   object:nil];
        self.connectStatus = [[fitpolo701CentralManager sharedInstance] getCurrentConnectStatus];
    }
    return self;
}

#pragma mark - Public Method
/**
 监测当前外设连接状况
 
 @param statusBlock 当前外设连接状态回调
 */
- (void)startMonitoringConnectStatus:(fitpolo701ConnectStatusChangedBlock)statusBlock{
    if (!statusBlock) {
        return;
    }
    fitpolo701_main_safe(^{statusBlock(self.connectStatus);});
    self.peripheralStatusChangedBlock = statusBlock;
}

/**
 获取当前中心蓝牙状态
 
 @return 当前中心蓝牙状态
 */
- (fitpolo701CentralManagerState)centralBluetoothStatus{
    fitpolo701CentralManager *manager = [fitpolo701CentralManager sharedInstance];
    if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
        //蓝牙可用
        return fitpolo701CentralManagerStateEnable;
    }
    return fitpolo701CentralManagerStateUnable;
}

/**
 监测当前中心的蓝牙状态
 
 @param statusBlock 当前中心蓝牙状态回调
 */
- (void)startMonitoringCentralManagerStatus:(fitpolo701CentralStatusChangedBlock)statusBlock{
    if (!statusBlock) {
        return;
    }
    fitpolo701CentralManager *manager = [fitpolo701CentralManager sharedInstance];
    if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
        //蓝牙可用
        fitpolo701_main_safe(^{statusBlock(fitpolo701CentralManagerStateEnable);});
    }else{
        //未知状态
        fitpolo701_main_safe(^{statusBlock(fitpolo701CentralManagerStateUnable);});
    }
    self.centralManagerStatusChangedBlock = statusBlock;
}

#pragma mark - Notification Method

/**
 中心开始连接外设
 */
-(void)startConnectPeripheral{
    self.connectStatus = fitpolo701ConnectStatusConnecting;
    [self connectStatusChanged];
}

/**
 中心连接外设成功
 */
- (void)connectPeripheralSuccess{
    self.connectStatus = fitpolo701ConnectStatusConnected;
    [self connectStatusChanged];
}

/**
 中心连接外设失败
 */
- (void)connectPeripheralFailed{
    self.connectStatus = fitpolo701ConnectStatusConnectedFailed;
    [self connectStatusChanged];
}

/**
 中心外设断开连接
 */
- (void)peripheralDisconnect{
    self.connectStatus = fitpolo701ConnectStatusDisconnect;
    [self connectStatusChanged];
}

/**
 中心蓝牙状态发生改变
 */
- (void)centralManagerStateChanged{
    if (!self.centralManagerStatusChangedBlock) {
        return;
    }
    fitpolo701_main_safe(^{
        fitpolo701CentralManager *manager = [fitpolo701CentralManager sharedInstance];
        if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
            //蓝牙可用
            self.centralManagerStatusChangedBlock(fitpolo701CentralManagerStateEnable);
        }else{
            //未知状态
            self.centralManagerStatusChangedBlock(fitpolo701CentralManagerStateUnable);
        }
    });
}

#pragma mark - private method
- (void)connectStatusChanged {
    if (!self.peripheralStatusChangedBlock) {
        return;
    }
    fitpolo701_main_safe(^{
        self.peripheralStatusChangedBlock(self.connectStatus);
    });
}

@end
