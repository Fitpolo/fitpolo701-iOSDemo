# fitpolo701-iOSDemo

支持pod，pod 'fitpolo701SDK'
#### 1.扫描
```
#import "fitpolo701SDK.h"

[fitpolo701CentralManager sharedInstance].scanDelegate = self;

//扫描701设备
[[fitpolo701CentralManager sharedInstance] startScanPeripheral];

#pragma mark - fitpolo701ScanPeripheralDelegate
/**
 中心开始扫描
 
 @param centralManager 中心
 */
- (void)fitpolo701CentralStartScan:(fitpolo701CentralManager *)centralManager{
    NSLog(@"Start scan");
}
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
                                centralManager:(fitpolo701CentralManager *)centralManager{
    NSLog(@"New peripheral:%@-%@-%@",peripheral.identifier.UUIDString,macAddress,peripheralName);
}
/**
 中心停止扫描
 
 @param centralManager 中心
 */
- (void)fitpolo701CentralStopScan:(fitpolo701CentralManager *)centralManager{
    NSLog(@"Stop scan");
}

```

#### 2.连接设备
##### 2.1 中心蓝牙状态改变和外设连接状态改变
```
[fitpolo701CentralManager sharedInstance].managerStateDelegate = self;
#pragma mark - fitpolo701CentralManagerStateDelegate
/**
 中心蓝牙状态改变
 
 @param managerState 中心蓝牙状态
 @param manager 中心
 */
- (void)fitpolo701CentralStateChanged:(fitpolo701CentralManagerState)managerState manager:(fitpolo701CentralManager *)manager{
    NSLog(@"当前中心状态:%@",@(managerState));
}

/**
 中心与外设连接状态改变
 
 @param connectState 外设连接状态
 @param manager 中心
 */
- (void)fitpolo701PeripheralConnectStateChanged:(fitpolo701ConnectStatus)connectState manager:(fitpolo701CentralManager *)manager{
    NSLog(@"当前连接状态:%@",@(connectState));
}
```
##### 2.2 通过identifier来连接设备

```
[[fitpolo701CentralManager sharedInstance] connectPeripheralWithIdentifier:@"0C-8D" connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        //Connect Success
		//Do some work
    } connectFailBlock:^(NSError *error) {
        //Connect Failed
	   // Do some work
    }];
```

##### 2.3连接指定设备

```
[[fitpolo701CentralManager sharedInstance] connectPeripheral:peripheral
                                         connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
    //Connect Success
		//Do some work
        }                                   connectFailBlock:^(NSError *error) {
     //Connect Failed
	   // Do some work
    }];
```

#### 3.数据接口调用
fitpolo701Interface包含了所有的数据接口部分，所有接口采用block形式回调。
```fitpolo705Interface.h```里面包含了所有的设置手环参数的接口，```fitpolo701Interface+RequestData.h```里面包含了所有的请求手环数据的接口，```fitpolo701UpgradeManager```包含了固件升级相关接口

