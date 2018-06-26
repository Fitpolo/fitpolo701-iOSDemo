//
//  fitpolo701ScanModel.h
//  testSDK
//
//  Created by aa on 2018/5/3.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface fitpolo701ScanModel : NSObject

@property (nonatomic, strong)CBPeripheral *peripheral;

/**
 701广播标识符为02
 */
@property (nonatomic, copy)NSString *typeIdenty;

@property (nonatomic, copy)NSString *macAddress;

@property (nonatomic, copy)NSString *peripheralName;

@end
