//
//  ViewController.m
//  GoodNightCharge
//
//  Created by bizan.com.mac03 on 2014/04/22.
//  Copyright (c) 2014年 bizan.com.kunren. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    int count,r,y;
    NSTimer* timer;
    UILabel *myLabel;
    EKEventStore *store;
    UIView *zentai;
    UIImageView *imageView; //f.
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    
    /* 背景画像の準備*/
    UIImage *imageData = [UIImage imageNamed:@"back1.jpg"];
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //イメージビューをつくる
    imageView = [[UIImageView alloc]initWithFrame:rect];
    imageView.image = imageData;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    
    /*　天気とかの部分のバーをつくるところ */
    //天気表示部分
    CGRect weatherRect = CGRectMake(0, 0, height, 64);
    UIView *weatherView = [[UIView alloc]initWithFrame:weatherRect];
    //    weatherView.backgroundColor = [UIColor redColor]; //確認用着色
    [self.view addSubview:weatherView];
    
    //ステータスバー部分
    CGRect barRect = CGRectMake(0, 0, height, 20);
    UIView *barView = [[UIView alloc]initWithFrame:barRect];
    barView.backgroundColor = [UIColor whiteColor];
    barView.alpha = 0.3;
    [self.view addSubview:barView];
    
    /* ここまで */

    
    
    y = 600;
//    zentai = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];    
//    CGRect zentaiFrame = zentai.frame;
//    zentaiFrame.origin = CGPointMake(0, self.view.frame.size.height+65);
    
    CGRect zentaiRect = CGRectMake(0,65,height,height);
    zentai = [[UIView alloc]initWithFrame:zentaiRect];
    
    [self calenderAuth];
    
    self.weather = [[Weather alloc]init];
    [self firstLoadMethod];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self powerCheck];
    
    
    
}

- (void)calenderAuth
{
    
    store = [[EKEventStore alloc] init];
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                // code here for when the user allows your app to access the calendar
                [self calenderPicker];
            } else {
                // code here for when the user does NOT allow your app to access the calendar
            }
        }];
    } else {
        // code here for iOS < 6.0
        [self calenderPicker];
    }
    
}

- (void)calenderPicker
{
    
    int i = 0;
    
    NSDate *start = [NSDate date];
    NSPredicate *predicate = [store predicateForEventsWithStartDate:start
                                                            endDate:[start dateByAddingTimeInterval:24*3600]
                                                          calendars:nil];
    NSArray *events = [store eventsMatchingPredicate:predicate];
    for(EKEvent *e in events)
    {
        NSLog(@"title=%@", e.title);
        NSLog(@"%@",e.startDate);
        
        // ラベルを配置していく
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 500+(i*90), 280, 75)];
        
        //ラベルの四隅を丸くする
        [[myLabel layer] setCornerRadius:3.0];
        [myLabel setClipsToBounds:YES];
        
        //テキストの色は白
        myLabel.textColor = [UIColor whiteColor];
        
        //背景色は半透明
        myLabel.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.3];
        
        // ラベルに配列の要素を代入
        myLabel.text = [NSString stringWithFormat:@"%@\n %@",e.title,e.startDate];
        
        
        myLabel.numberOfLines = 3;
        
        
        // ラベルをビューに設定する
        [zentai addSubview:myLabel];
        [zentai sizeToFit];
        
        //ビューをUIviewへ設定する
        [self.view addSubview:zentai];
        
        i++;
        
    }
    
}

- (void)firstLoadMethod
{
    
    self.locationManager = [[CLLocationManager alloc] init];//ヘッダで宣言したインスタンスの初期化
    
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        // 測位開始
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
        [self.weather alertViewMethod];
    }
    
}


- (void)locationManager:(CLLocationManager *)manager//引数managerはシステムからの情報か？CLLocationManagerクラスにある位置情報を取得するlocationManagerメソッド
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    self.latitude = [newLocation coordinate].latitude;
    self.longitude = [newLocation coordinate].longitude;
    
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          self.latitude, self.longitude);
    
    [self.locationManager stopUpdatingLocation];
    //本日の天気情報を取得
    [self urlWithAddress];
    
}




// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる関数
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    [self.weather alertViewMethod];
}




//位置情報もしくは住所情報からWEBAPIにアクセスする関数
- (void)urlWithAddress
{
    
    //取得した経度・緯度情報をAPIのURLに組み込む
    NSString *urlApi1 = @"http://api.openweathermap.org/data/2.5/forecast?lat=";
    NSString *urlApi2 = @"&lon=";
    NSString *urlApi3 = @"&cnt=1";
    NSString *urlApi = [NSString stringWithFormat:@"%@%f%@%f%@",urlApi1,self.latitude,urlApi2,self.longitude,urlApi3];
    
    //気温情報取得
    self.weather.jsonObject = [self.weather webAPIMethod:urlApi];
    [self.weather takeInfo];
    
}

//電源状態を確認する関数です。
- (void)powerCheck
{
    // デバイスのインスタンスを取得します。
    UIDevice* device = [UIDevice currentDevice];
    
    // バッテリーの状態変化の検出を有効化します。
    device.batteryMonitoringEnabled = YES;
    
    //UIDeviceクラスのbatteryLevelでバッテリーの残量を0～1の値で取得します。
    NSLog(@"batteryLevel:%f",device.batteryLevel);
    
    
    //UIDeviceクラスのbatteryStateでバッテリーの状態を取得します。
    NSLog(@"batteryState:%d",device.batteryState);
    
    if (device.batteryState == (long)UIDeviceBatteryStateUnknown)
    {
        //UIDeviceBatteryStateUnknown:バッテリー状態取得不能
        NSLog(@"バッテリー状態取得不能");
    }
    if (device.batteryState == (long)UIDeviceBatteryStateUnplugged)
    {
        //UIDeviceBatteryStateUnplugged:バッテリー使用中
        NSLog(@"バッテリー使用中");
    }
    if (device.batteryState == (long)UIDeviceBatteryStateCharging)
    {
        //UIDeviceBatteryStateCharging:バッテリー充電中
        NSLog(@"バッテリー充電中");
    }
    if (device.batteryState == (long)UIDeviceBatteryStateFull)
    {
        //UIDeviceBatteryStateFull:バッテリーフル充電状態
        NSLog(@"バッテリーフル充電状態");
    }
    
    
    // バッテリー状態が変化した通知（UIDeviceBatteryStateDidChangeNotification）を受け取ったら、deviceBatteryStateDidChangeNotification関数を呼びます。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
}



// あらかじめ、バッテリー状態の変化通知が届いた時の処理を行うメソッドを準備しておきます。
- (void)deviceBatteryStateDidChangeNotification:(NSNotification*)note
{
    NSLog(@"電源状態が変化しました");
    //ここからカレンダー情報を取得して、エンドロールを流す関数を記載します。
    
    [self mainloop];
    
}

-(void)mainloop
{
    //NStimerが有効になっていなければ、timerを止める
	if ([timer isValid])
    {
		[timer invalidate];
	}
    
    //自動スクロールメソッドを動かす
	timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                             target:self
                                           selector:@selector(timerDidFire)
                                           userInfo:nil
                                            repeats:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//自動スクロール開始
- (void)timerDidFire
{
    
    y -= 1;
    
    zentai.center = CGPointMake(160, y);
    
    if (y < 30)
    {
        [timer invalidate];
    }
}

//回転に応じてレイアウト変更
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;

    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {//ふつうの向きになったとき
        UIImage *imageData = [UIImage imageNamed:@"back1.jpg"];
        imageView.image = imageData;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.center = CGPointMake(width/2, height/2);
        imageView.bounds = CGRectMake(0, 0, width, height);
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
             interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//よこむきに回転させたとき
        
        UIImage *imageData2 = [UIImage imageNamed:@"back2.jpg"];
        imageView.image = imageData2;
        imageView.center = CGPointMake(height/2, width/2);
        imageView.bounds = CGRectMake(0, 0, height, width);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}



@end
