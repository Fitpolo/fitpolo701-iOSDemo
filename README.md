# fitpolo701-iOSDemo

support pod，pod 'fitpolo701SDK'
#### 1 scan
```
#import "fitpolo701SDK.h"

[fitpolo701CentralManager sharedInstance].scanDelegate = self;

//scan 701 device
[[fitpolo701CentralManager sharedInstance] startScanPeripheral];

#pragma mark - fitpolo701ScanPeripheralDelegate
/**
center start scan

@param centralManager center
*/
- (void)fitpolo701CentralStartScan:(fitpolo701CentralManager *)centralManager{
NSLog(@"Start scan");
}
/**
scanned new device

@param peripheral scanned device
@param macAddress  device's Mac address
@param peripheralName  device name
@param centralManager center
*/
- (void)fitpolo701CentralScanningNewPeripheral:(CBPeripheral *)peripheral
macAddress:(NSString *)macAddress
peripheralName:(NSString *)peripheralName
centralManager:(fitpolo701CentralManager *)centralManager{
NSLog(@"New peripheral:%@-%@-%@",peripheral.identifier.UUIDString,macAddress,peripheralName);
}
/**
center stop scanning

@param centralManager center
*/
- (void)fitpolo701CentralStopScan:(fitpolo701CentralManager *)centralManager{
NSLog(@"Stop scan");
}

```

#### 2.connect device
##### 2.1 Central Bluetooth status change and peripheral connection status change
```
[fitpolo701CentralManager sharedInstance].managerStateDelegate = self;
#pragma mark - fitpolo701CentralManagerStateDelegate
/**
Central Bluetooth status change

@param managerState Central Bluetooth status
@param manager center
*/
- (void)fitpolo701CentralStateChanged:(fitpolo701CentralManagerState)managerState manager:(fitpolo701CentralManager *)manager{
NSLog(@"peripheral connection status change:%@",@(managerState));
}

/**
Center and peripheral connection status change

@param connectState Peripheral connection status
@param managercenter
*/
- (void)fitpolo701PeripheralConnectStateChanged:(fitpolo701ConnectStatus)connectState manager:(fitpolo701CentralManager *)manager{
NSLog(@"Current connection status:%@",@(connectState));
}
```
##### 2.2 through identifier to connect device
```
[[fitpolo701CentralManager sharedInstance] connectPeripheralWithIdentifier:@"0C-8D" connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
//Connect Success
//Do some work
} connectFailBlock:^(NSError *error) {
//Connect Failed
// Do some work
}];
```

##### 2.3connect appointed device

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

#### 3.Data interface call
fitpolo701Interface Contains all the data interface parts, all interfaces callback in block form
```fitpolo705Interface.h```It contains all the interfaces for setting the bracelet parameters.，```fitpolo701Interface+RequestData.h```contains all the interfaces for requesting bracelet data.，```fitpolo701UpgradeManager```Contains firmware upgrade related interfaces
