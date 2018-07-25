//
//  HCKMainViewController.m
//  testSDK
//
//  Created by aa on 2018/3/20.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "HCKMainViewController.h"
#import "fitpolo701SDK.h"

static NSString *const mainCellIdenty = @"mainCellIdenty";

@interface HCKMainViewController ()<UITableViewDelegate, UITableViewDataSource, fitpolo701ScanPeripheralDelegate, fitpolo701CentralManagerStateDelegate>

@property (nonatomic, strong)UIButton *button;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)fitpolo701UpgradeManager *updateManager;

@end

@implementation HCKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"Test"];
    [self.view addSubview:self.button];
    [self.view addSubview:self.tableView];
    [self loadData];
    [fitpolo701CentralManager sharedInstance].scanDelegate = self;
    [fitpolo701CentralManager sharedInstance].managerStateDelegate = self;
}

#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdenty];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mainCellIdenty];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self didSelectedRow:indexPath.row];
}

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

#pragma mark -

- (void)loadData{
    [self.dataList addObject:@"vibrate"];
    [self.dataList addObject:@"set the metric unit"];
    [self.dataList addObject:@"set the imperial unit"];
    [self.dataList addObject:@"set ancs"];
    [self.dataList addObject:@"set time"];
    [self.dataList addObject:@"set personal information"];
    [self.dataList addObject:@"set time base"];
    [self.dataList addObject:@"set switch wrist to light up the screen"];
    [self.dataList addObject:@"Close all the alarm clock"];
    [self.dataList addObject:@"Set up eight clock"];
    [self.dataList addObject:@"last screen display"];
    [self.dataList addObject:@"Open the sedentary remind"];
    [self.dataList addObject:@"Close the sedentary remind"];
    [self.dataList addObject:@"heart rate collection interval"];
    [self.dataList addObject:@"sets the screen display"];
    [self.dataList addObject:@"Close ancs"];
    [self.dataList addObject:@"Read bracelet battery power"];
    [self.dataList addObject:@"hardware parameters"];
    [self.dataList addObject:@"firmware version number"];
    [self.dataList addObject:@"Request within the version number"];
    [self.dataList addObject:@"Get pedometer data"];
    [self.dataList addObject:@"Get sleep data"];
    [self.dataList addObject:@"Get heart rate data"];
    [self.dataList addObject:@"firmware update"];
    [self.dataList addObject:@"destroy singleton"];
    [self.tableView reloadData];
}

- (void)buttonPressed{
    [[fitpolo701CentralManager sharedInstance] startScanPeripheral];
    fitpolo701WS(weakSelf);
    [[fitpolo701CentralManager sharedInstance] connectPeripheralWithIdentifier:@"0C-8D" connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        [weakSelf showAlertWithMsg:@"连接成功"];
    } connectFailBlock:^(NSError *error) {
        [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)didSelectedRow:(NSInteger)row{
    fitpolo701WS(weakSelf);
    if (row == 0) {
        [fitpolo701Interface peripheralVibration:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 1){
        [fitpolo701Interface peripheralUnitSwitch:fitpolo701MetricSystem sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 2){
        [fitpolo701Interface peripheralUnitSwitch:fitpolo701Imperial sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 3){
        fitpolo701AncsModel *model = [[fitpolo701AncsModel alloc] init];
        model.openSMS = YES;
        model.openPhone = YES;
        model.openWeChat = YES;
        model.openQQ = YES;
        model.openWhatsapp = YES;
        model.openTwitter = YES;
        model.openSnapchat = YES;
        model.openFacebook = YES;
        model.openSkype = YES;
        [fitpolo701Interface peripheralCorrespondANCSNotice:model sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 4){
        [fitpolo701Interface peripheralSetDate:[NSDate date] sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 5){
        [fitpolo701Interface peripheralSetUserWeight:70 height:175 age:29 gender:fitpolo701Male sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 6){
        [fitpolo701Interface peripheralSetTimeFormat:fitpolo70124Hour sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 7){
        [fitpolo701Interface peripheralOpenPalmingBrightScreen:YES sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 8){
        [fitpolo701Interface peripheralSetAlarmClock:nil sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 9){
        NSMutableArray *list = [NSMutableArray array];
        for (NSInteger i = 0; i < 8; i ++) {
            [list addObject:[self getModel]];
        }
        [fitpolo701Interface peripheralSetAlarmClock:list sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 10){
        [fitpolo701Interface peripheralRemindLastScreenDisplay:YES sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 11){
        [fitpolo701Interface peripheralSetSedentaryRemind:YES startHour:0 startMinutes:26 endHour:23 endMinutes:1 sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        
    }else if (row == 12){
        [fitpolo701Interface peripheralSetSedentaryRemind:NO startHour:0 startMinutes:55 endHour:23 endMinutes:1 sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 13){
        [fitpolo701Interface peripheralSetHeartRateAcquisitionInterval:fitpolo701HeartRateAcquisitionInterval20Min sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 14){
        fitpolo701ScreenDisplayModel *model = [[fitpolo701ScreenDisplayModel alloc] init];
        model.turnOnCaloriesPage = YES;
        model.turnOnStepPage = YES;
        [fitpolo701Interface peripheralSetScreenDisplay:model sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 15){
        [fitpolo701Interface peripheralCloseANCSWithSucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 16){
        [fitpolo701Interface requestPeripheralBatteryWithSucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 17){
        [fitpolo701Interface requestPeripheralHardwareParametersWithSucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 18){
        [fitpolo701Interface requestPeripheralFirwareVersionWithSucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 19){
        [fitpolo701Interface requestPeripheralInternalVersionWithSucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 20){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo701Interface requestPeripheralStepDataWithDate:date sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 21){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo701Interface requestPeripheralSleepDataWithDate:date sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        
    }else if (row == 22){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo701Interface requestPeripheralHeartRateDataWithDate:date sucBlock:^(id returnData) {
            [weakSelf showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }else if (row == 23){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BORD_CC_01" ofType:@"bin"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        [self.updateManager startUpdateProcessWithPackageData:fileData successBlock:^{
            [weakSelf showAlertWithMsg:@"Success"];
        } progressBlock:^(CGFloat progress) {
            NSLog(@"progress:%f",progress);
        } failedBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        
    }else if (row == self.dataList.count - 1){
        [fitpolo701CentralManager singletonDestroyed];
    }
}

- (fitpolo701AlarmClockModel *)getModel{
    fitpolo701AlarmClockModel *model = [[fitpolo701AlarmClockModel alloc] init];
    model.hour = 10;
    model.minutes = 25;
    model.clockType = fitpolo701AlarmClockSleep;
    fitpolo701StatusModel *statusModel = [[fitpolo701StatusModel alloc] init];
    statusModel.sundayIsOn = YES;
    statusModel.fridayIsOn = YES;
    model.statusModel = statusModel;
    return model;
}

- (void)showAlertWithMsg:(NSString *)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dismiss"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:moreAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//29-37
- (UILabel *)getLabel{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.f];
    return label;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 70.f, self.view.frame.size.width - 2 * 15, 400.f) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:CGRectMake(15.f, self.view.frame.size.height - 40.f - 35.f, self.view.frame.size.width - 2 * 15, 40.f)];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_button setTitle:@"button" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (fitpolo701UpgradeManager *)updateManager{
    if (!_updateManager) {
        _updateManager = [[fitpolo701UpgradeManager alloc] init];
    }
    return _updateManager;
}

@end

