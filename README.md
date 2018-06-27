# fitpolo701-iOSDemo

#### 1.扫描
```
#import "fitpolo701SDK.h"

[fitpolo701CentralManager sharedInstance].scanDelegate = self;

//扫描701设备
[[fitpolo701CentralManager sharedInstance] startScanPeripheral];

/*
扫描代理
@protocol fitpolo701ScanPeripheralDelegate <NSObject>

@optional
- (void)fitpolo701StartScan;
- (void)fitpolo701ScanNewPeripheral:(NSDictionary *)dic;
- (void)fitpolo701StopScan;

@end
*/

```

#### 2.连接设备
##### 2.1 通过identifier来连接设备

```
[[fitpolo701CentralManager sharedInstance] connectPeripheralWithIdentifier:@"73-15"
                                                               connectType:fitpolo701ConnectPeripheralWithMacAddressLowFour
                                                       connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        //Connect Success
		    //Do some work
    }                                                     connectFailBlock:^(NSError *error) {
        //Connect Failed
	     // Do some work
    }];
```

##### 2.2连接指定设备

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
```fitpolo705Interface.h```里面包含了所有的设置手环参数的接口，```fitpolo701Interface+RequestData.h```里面包含了所有的11请求手环数据的接口，```fitpolo701Interface+Update```包含了固件升级相关接口


