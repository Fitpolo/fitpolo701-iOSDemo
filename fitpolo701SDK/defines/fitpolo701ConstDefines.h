
#pragma mark -=====================HCKCentralManager与外设连接状态的通知部分=====================
//中心开始连接外设
static NSString *const fitpolo701StartConnectPeripheralNotification = @"fitpolo701StartConnectPeripheralNotification";
//连接设备成功
static NSString *const fitpolo701ConnectSuccessNotification = @"fitpolo701ConnectSuccessNotification";
//连接设备失败
static NSString *const fitpolo701ConnectFailedNotification = @"fitpolo701ConnectFailedNotification";
//与外设断开连接
static NSString *const fitpolo701DisconnectPeripheralNotification = @"fitpolo701DisconnectPeripheralNotification";
//中心蓝牙状态改变
static NSString *const fitpolo701BluetoothStateChangedNotification = @"fitpolo701BluetoothStateChangedNotification";

/*=========================  peripheralManager连接结果通知  =========================*/
//peripheralManager连接设备失败
static NSString *const fitpolo701PeripheralConnectedFailedNotification = @"fitpolo701PeripheralConnectedFailedNotification";
//peripheralManager连接设备成功
static NSString *const fitpolo701PeripheralConnectedSuccessNotification = @"fitpolo701PeripheralConnectedSuccessNotification";

//外设固件升级结果通知,由于升级固件采用的是无应答定时器发送数据包，所以当产生升级结果的时候，需要靠这个通知来结束升级过程
static NSString *const fitpolo701PeripheralUpdateResultNotification = @"fitpolo701PeripheralUpdateResultNotification";

