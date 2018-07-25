//
//  CBPeripheral+fitpolo701Characteristic.h
//  fitpolo701SDKDemo
//
//  Created by aa on 2018/7/23.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (fitpolo701Characteristic)

@property (nonatomic, strong, readonly)CBCharacteristic *commandSend;

@property (nonatomic, strong, readonly)CBCharacteristic *commandNotify;

- (void)update701CharacteristicsForService:(CBService *)service;

- (BOOL)fitpolo701ConnectSuccess;

@end
