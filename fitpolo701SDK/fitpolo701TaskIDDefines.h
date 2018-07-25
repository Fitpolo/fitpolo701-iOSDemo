
typedef NS_ENUM(NSInteger, fitpolo701TaskOperationID) {
    fitpolo701DefaultTaskOperationID,            //默认指令
    fitpolo701VibrationOperation,                //震动指令
    fitpolo701SetUnitOperation,                  //切换进制单位
    fitpolo701OpenANCSOperation,                 //开启ancs
    fitpolo701SetANCSOptionsOperation,           //设置开启ancs的选项
    fitpolo701SetDateOperation,                  //设置日期
    fitpolo701SetUserInfoOperation,              //设置个人信息
    fitpolo701SetTimeFormatOperation,            //设置时间进制
    fitpolo701OpenPalmingBrightScreenOperation,  //设置翻腕亮屏
    fitpolo701SetAlarmClockOperation,            //设置闹钟
    fitpolo701RemindLastScreenDisplayOperation,  //记住上一次屏幕显示
    fitpolo701SetSedentaryRemindOperation,       //设置久坐提醒
    fitpolo701SetHeartRateAcquisitionIntervalOperation,  //设置心率采集间隔
    fitpolo701SetScreenDisplayOperation,         //设置屏幕显示
    fitpolo701CloseANCSOperation,                //关闭ancs功能
    fitpolo701StartUpdateOperation,              //开启升级
    
    fitpolo701GetMemoryDataOperation,            //获取memory数据
    fitpolo701GetHardwareParametersOperation,    //获取硬件参数
    fitpolo701GetFirmwareVersionOperation,       //获取固件版本号
    fitpolo701GetInternalVersionOperation,       //获取内部版本号
    fitpolo701GetANCSOptionsOperation,           //获取ancs选项
    fitpolo701GetStepDataOperation,              //获取计步数据
    fitpolo701GetSleepIndexOperation,            //获取睡眠index数据
    fitpolo701GetSleepRecordOperation,           //获取睡眠record数据
    fitpolo701GetHeartDataOperation,             //获取心率数据
    fitpolo701GetAlarmClockDataOperation,        //获取闹钟数据
    fitpolo701GetSedentaryRemindOperation,       //获取久坐提醒数据
    fitpolo701GetConfigurationParametersOperation,  //获取配置参数
};
