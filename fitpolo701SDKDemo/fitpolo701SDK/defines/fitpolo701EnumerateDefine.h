
/*
 自定义的错误码
 */
typedef NS_ENUM(NSInteger, fitpolo701CustomErrorCode){
    fitpolo701BlueDisable = -10000,                                     //当前手机蓝牙不可用
    fitpolo701ConnectedFailed = -10001,                                 //连接外设失败
    fitpolo701PeripheralDisconnected = -10002,                          //当前外部连接的设备处于断开状态
    fitpolo701CharacteristicError = -10003,                             //特征为空
    fitpolo701RequestPeripheralDataError = -10004,                      //请求手环数据出错
    fitpolo701ParamsError = -10005,                                     //输入的参数有误
};

typedef NS_ENUM(NSInteger, fitpolo701ConnectStatus) {
    fitpolo701ConnectStatusUnknow,                                           //未知状态
    fitpolo701ConnectStatusConnecting,                                       //正在连接
    fitpolo701ConnectStatusConnected,                                        //连接成功
    fitpolo701ConnectStatusConnectedFailed,                                  //连接失败
    fitpolo701ConnectStatusDisconnect,                                       //连接断开
};

typedef NS_ENUM(NSInteger, fitpolo701CentralManagerState) {
    fitpolo701CentralManagerStateEnable,                           //可用状态
    fitpolo701CentralManagerStateUnable,                           //不可用
};

typedef NS_ENUM(NSInteger, fitpolo701Unit) {
    fitpolo701MetricSystem,         //公制
    fitpolo701Imperial,             //英制
};

typedef NS_ENUM(NSInteger, fitpolo701Gender) {
    fitpolo701Male,             //男性
    fitpolo701Female,           //女性
};

typedef NS_ENUM(NSInteger, fitpolo701TimeFormat) {
    fitpolo70124Hour,         //24小时制
    fitpolo70112Hour,         //12小时制
};

typedef NS_ENUM(NSInteger, fitpolo701AlarmClockIndex) {
    fitpolo701AlarmClockIndexFirst,         //第一组闹钟
    fitpolo701AlarmClockIndexSecond,        //第二组闹钟
};

typedef NS_ENUM(NSInteger, fitpolo701HeartRateAcquisitionInterval) {
    fitpolo701HeartRateAcquisitionIntervalClose,    //关闭心率采集功能
    fitpolo701HeartRateAcquisitionInterval10Min,    //10分钟
    fitpolo701HeartRateAcquisitionInterval20Min,    //20分钟
    fitpolo701HeartRateAcquisitionInterval30Min,    //30分钟
};

typedef NS_ENUM(NSInteger, fitpolo701RequestDataWithTimeStamp) {
    fitpolo701RequestStepDataWithTimeStamp,         //时间戳请求计步数据
    fitpolo701RequestSleepIndexDataWithTimeStamp,   //时间戳请求睡眠index数据
    fitpolo701RequestSleepRecordDataWithTimeStamp,  //时间戳请求睡眠record数据
    fitpolo701RequestHeartRateDataWithTimeStamp,    //时间戳请求心率数据
};

