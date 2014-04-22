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
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    
    y = 600;
    
    
    zentai = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 269, 1000)];
    
//    zentai = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
//    
//    CGRect zentaiFrame = zentai.frame;
//    
//    zentaiFrame.origin = CGPointMake(0, self.view.frame.size.height + 100);
//    
//    zentai.frame = zentaiFrame;
    
    [self calenderAuth];
    
    self.weather = [[Weather alloc]init];
    [self firstLoadMethod];
    
    //音源設定
    NSString *bgmPath = [[NSBundle mainBundle]pathForResource:@"tw059" ofType:@"mp3"];  //ファイル名と拡張子が引数になる
    NSURL *bgmUrl = [NSURL fileURLWithPath:bgmPath];  //音声ファイルの場所をurl変数に置き換える
    
    NSError *error;
    self.bgm = [[AVAudioPlayer alloc]initWithContentsOfURL:bgmUrl error:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [self powerCheck];
    
    //電源ステータス
    self.pawerstatus = NO;
    
    

    
    
    
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
        NSLog(@"%@",e.location);
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit |
                                       NSMonthCalendarUnit  |
                                       NSDayCalendarUnit    |
                                       NSHourCalendarUnit   |
                                       NSMinuteCalendarUnit |
                                       NSSecondCalendarUnit
                                                  fromDate:e.startDate];
        NSInteger thisHour = (int)dateComps.hour;
        NSLog(@"時間＝%d",thisHour);
        NSInteger thisMinute = (int)dateComps.minute;
        NSLog(@"分＝%d",thisMinute);
        
        NSString *thisMinuteString;
        if (thisMinute<10) {
            thisMinuteString = [NSString stringWithFormat:@"0%d",thisMinute];
        }else{
            thisMinuteString = [NSString stringWithFormat:@"%d",thisMinute];
        }
        
        
        NSAttributedString *scheduletime = [[NSAttributedString alloc]initWithString:
                                    [NSString stringWithFormat:@"%d:%@\n",thisHour,thisMinuteString]
                                                                  attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:13]}];
        
        NSAttributedString *scheduletitle = [[NSAttributedString alloc]initWithString:
                                    [NSString stringWithFormat:@"　%@\n",e.title]
                                                                  attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:21]}];
        
        NSAttributedString *schedulelocation;
        if (!(e.location == NULL)) {
        schedulelocation = [[NSAttributedString alloc]initWithString:
                                             [NSString stringWithFormat:@"　　%@",e.location]
                                                                           attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        }else{
            schedulelocation = [[NSAttributedString alloc]initWithString:
                                [NSString stringWithFormat:@"　　"]
                                                              attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        }
        
        NSMutableAttributedString *endSchedule = [[NSMutableAttributedString alloc] initWithAttributedString:scheduletime];
        [endSchedule appendAttributedString:scheduletitle];
        [endSchedule appendAttributedString:schedulelocation];
        
    
        // ラベルを配置していく
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 600+(i*90), 230, 80)];
        
        //ラベルの四隅を丸くする
        [[myLabel layer] setCornerRadius:3.0];
        [myLabel setClipsToBounds:YES];
        
        //テキストの色は白
        myLabel.textColor = [UIColor whiteColor];
        
        //背景色は半透明
        myLabel.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.3];
        
        // ラベルに配列の要素を代入
        myLabel.attributedText = endSchedule;
        
        
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
    
    self.pawerstatus = UIDeviceBatteryStateUnplugged;
    
    if (self.pawerstatus == YES) {
         [self bgmstart];
         [self mainloop];
        
        //ボタンを作成
        [self buttonUp];
        [self buttonDown];

    }else if(self.pawerstatus == NO){
        [self.bgm stop];
        
        
        
    }
    
   
    
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
    
    if (y < -70)
    {
        [timer invalidate];
    }
}


-(void)bgmstart{
    [self.bgm stop];
    
    [self.bgm setNumberOfLoops:-1];  //繰り返し設定 0が１回、-1がエンドレス
    [self.bgm prepareToPlay];
    [self.bgm play];
    
    
}

//上に動かす
- (void)moveUp{
    [timer invalidate];
    y -= 150;
    
    zentai.center = CGPointMake(160, y);
    
}

//上に動かすボタン
- (void)buttonUp{
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    
    // ボタンの位置を設定
    button.frame = CGRectMake(270, 30, 44, 44);
    
    // キャプションを設定
    [button setBackgroundImage:[UIImage imageNamed:@"arrow 16.png"] forState:UIControlStateNormal];
    
    //ボタンの背景色を入れて角を丸くする
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setAlpha:0.2];
    [[button layer] setCornerRadius:3.0];
    [button setClipsToBounds:YES];

    // キャプションに合わせてサイズを設定
    [button sizeToFit];
    
    
    
    // ボタンがタップされたときに呼ばれるメソッドを設定
    [button addTarget:self
                action:@selector(moveUp)
                forControlEvents:UIControlEventTouchUpInside];
    
    // ボタンをビューに追加
    [self.view addSubview:button];

}

//下に動かす
- (void)moveDown{
    [timer invalidate];
    y += 150;
    
    zentai.center = CGPointMake(160, y);
    
}

//下に動かすボタン
- (void)buttonDown{
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    
    // ボタンの位置を設定
    button.frame = CGRectMake(270, 425, 44, 44);
    
    
    // キャプションを設定
    [button setBackgroundImage:[UIImage imageNamed:@"arrow 15.png"]  forState:UIControlStateNormal];
    
    // キャプションに合わせてサイズを設定
    [button sizeToFit];
    
    //ボタンの背景色を入れて角を丸くする
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setAlpha:0.2];
    [[button layer] setCornerRadius:3.0];
    [button setClipsToBounds:YES];
    
    
    // ボタンがタップされたときに呼ばれるメソッドを設定
    [button addTarget:self
               action:@selector(moveDown)
     forControlEvents:UIControlEventTouchUpInside];
    
    // ボタンをビューに追加
    [self.view addSubview:button];
    
}


@end
