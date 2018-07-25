//
//  CBPeripheral+fitpolo701Characteristic.m
//  fitpolo701SDKDemo
//
//  Created by aa on 2018/7/23.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "CBPeripheral+fitpolo701Characteristic.h"
#import <objc/runtime.h>

static const char *writeCharacteristic = "writeCharacteristic";
static const char *notifyCharacteristic = "notifyCharacteristic";

@implementation CBPeripheral (fitpolo701Characteristic)

- (void)update701CharacteristicsForService:(CBService *)service{
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
        return;
    }
    for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC1"]]) {
            objc_setAssociatedObject(self, &writeCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
            objc_setAssociatedObject(self, &notifyCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (CBCharacteristic *)commandSend{
    return objc_getAssociatedObject(self, &writeCharacteristic);
}

- (CBCharacteristic *)commandNotify{
    return objc_getAssociatedObject(self, &notifyCharacteristic);
}

- (BOOL)fitpolo701ConnectSuccess{
    if (!self.commandSend) {
        return NO;
    }
    if (!self.commandNotify) {
        return NO;
    }
    return YES;
}

@end
