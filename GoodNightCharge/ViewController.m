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
    int count,scrollspeed,scrolllimit,r,y;
    NSTimer* timer;
    UILabel *myLabel;
    EKEventStore *store;
    UIView *zentai;
    UIImageView *imageView; //f.
    UILabel *tomorrow;
    UILabel *degree;
    UIImageView *weatherIconView;
    UIImageView *weatherCIconView;
    UIAlertView *alert;
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{

    /*
    y = 600;
    scrollspeed = -5;
    scrolllimit = -17;
    */
    
    
//    zentai = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
//    
//    CGRect zentaiFrame = zentai.frame;
//    
//    zentaiFrame.origin = CGPointMake(0, self.view.frame.size.height + 100);
//    
//    zentai.frame = zentaiFrame;
    
    
    
    //[self calenderAuth];
    
    self.weather = [[Weather alloc]init];
    
    [self firstLoadMethod];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //イメージビューをつくる
    
    /* 背景画像の準備*/
    UIImage *imageData = [UIImage imageNamed:@"back1.jpg"];
    
    imageView = [[UIImageView alloc]initWithFrame:rect];
    imageView.image = imageData;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    
    //背景トーンを落とすためのレイヤーを重ねる
    UIView *rayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, height, height)];
    rayer.alpha = 0.2;
    rayer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rayer];
    
    //EKEventStore初期化
    store = [[EKEventStore alloc] init];
    

}

- (void)calenderAuth
{
    
    /*
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
    }*/
    
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    // iOS5: ユーザーに許可を求める必要がない
    if (version < 6.0) {
        [self calenderPicker];
    }
    
    // iOS6: ユーザーに許可を求める必要がある
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusNotDetermined: {
            // ユーザーにまだアクセスの許可を求めていない場合
            // 「このアプリがカレンダーへのアクセスを求めています」というアラートが表示される
            [store requestAccessToEntityType:EKEntityTypeEvent
                                       completion:^(BOOL granted, NSError *error)
             {
                 if (granted) {
                     // 「OK」をタップ
                     [self calenderPicker];
                 } else {
                     // 「許可しない」をタップ
                     // UIAlertView の表示を main thread で行う
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [[[UIAlertView alloc] initWithTitle:@"確認"
                                                     message:@"このアプリのカレンダーへのアクセスを許可するには、プライバシーから設定する必要があります。"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil]
                          show];
                     });
                 }
             }];
        }
            break;
        case EKAuthorizationStatusAuthorized:
            // ユーザーから許可されている
            [self calenderPicker];
            break;
        case EKAuthorizationStatusRestricted:
            // 「設定」→「一般」→「機能制限」→「カレンダー」→
            // 「変更を許可しない」が選択されている
        case EKAuthorizationStatusDenied:
            // ユーザーから拒否されている
            // ユーザーにアクセスの許可を求めた後、「許可しない」をタップするとこれが呼ばれる
            // 「設定」→「プライバシー」→「カレンダー」からアプリを許可してもらう必要がある
            [[[UIAlertView alloc] initWithTitle:@"確認"
                                        message:@"カレンダーに対する変更を機能制限されているか、プライバシーから許可されていません。"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
            
            break;
        default:
            break;
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
    NSMutableArray *myLabels = [[NSMutableArray alloc] init];
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
        int thisHour = (int)dateComps.hour;
        NSLog(@"時間＝%d",thisHour);
        int thisMinute = (int)dateComps.minute;
        NSLog(@"分＝%d",thisMinute);
        
        NSString *thisMinuteString;
        if (thisMinute<10) {
            thisMinuteString = [NSString stringWithFormat:@"0%d",thisMinute];
        }else{
            thisMinuteString = [NSString stringWithFormat:@"%d",thisMinute];
        }
        
        
        NSAttributedString *scheduletime = [[NSAttributedString alloc]initWithString:
                                    [NSString stringWithFormat:@" %d:%@\n",thisHour,thisMinuteString]
                                                                  attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:13]}];
        
        NSAttributedString *scheduletitle = [[NSAttributedString alloc]initWithString:
                                    [NSString stringWithFormat:@"　%@\n",e.title]
                                                                  attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:21]}];
        
        NSAttributedString *schedulelocation;
        if (!(e.location == NULL)) {
        schedulelocation = [[NSAttributedString alloc]initWithString:
                                             [NSString stringWithFormat:@"     location at %@",e.location]
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
        
        [myLabels addObject:myLabel];
        
        i++;
        
        
    }
    zentai = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 269, 1000)];
    // ラベルをビューに設定する
    for (UILabel *label in myLabels) {
        [zentai addSubview:label];
    }
    
    //ビューをUIviewへ設定する
    [self.view addSubview:zentai];
   
    
}

- (void)firstLoadMethod
{
    //音源設定
    NSString *bgmPath = [[NSBundle mainBundle]pathForResource:@"tw059" ofType:@"mp3"];  //ファイル名と拡張子が引数になる
    NSURL *bgmUrl = [NSURL fileURLWithPath:bgmPath];  //音声ファイルの場所をurl変数に置き換える
    
    NSError *error;
    self.bgm = [[AVAudioPlayer alloc]initWithContentsOfURL:bgmUrl error:&error];
    
    //電源状態確認
    [self powerCheck];
    

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
    [self iconAndTempViewMethod];
    
    

}




// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる関数
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    [self.weather alertViewMethod];
}


- (void)iconAndTempViewMethod{
    
    /*　天気、tomorrow、文字列表示部分の生成 */
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat height = screenSize.size.height;
    
    //取得した天気、気温を表示するビュー
    CGRect weatherRect = CGRectMake(0, 0, height, 64);
    UIView *weatherView = [[UIView alloc]initWithFrame:weatherRect];
//    weatherView.backgroundColor = [UIColor whiteColor]; //範囲確認用着色
//    weatherView.alpha = 0.2;
    [self.view addSubview:weatherView];
    
    //文字ラベル生成。先に現在時刻を取得
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit |
                                   NSMonthCalendarUnit  |
                                   NSDayCalendarUnit    |
                                   NSHourCalendarUnit   |
                                   NSMinuteCalendarUnit |
                                   NSSecondCalendarUnit
                                              fromDate:date];
    
    int thisTime = (int)dateComps.hour;
    
    tomorrow = [[UILabel alloc]initWithFrame:CGRectMake(10, 23, 78, 20)];
    
    if (thisTime > 9) {
        tomorrow.text = @"tomorrow";
    }else{
        tomorrow.text = @"today";
    }
    tomorrow.font = [UIFont fontWithName:@"AppleGothic" size:15];
    tomorrow.textColor = [UIColor whiteColor];
    //    tomorrow.backgroundColor = [UIColor blackColor];//範囲確認用着色
    [weatherView addSubview:tomorrow];
    
    
    //気温ラベル生成
    degree = [[UILabel alloc]initWithFrame:CGRectMake(5, 43, 65, 20)];
    NSLog(@"iconView=%@",self.weather.temp);
    //degree.text = self.weather.temp;
    degree.text = [NSString stringWithFormat:@"%@",self.weather.temp];
    degree.font = [UIFont fontWithName:@"AppleGothic" size:18];
    degree.textColor = [UIColor whiteColor];
    degree.textAlignment = NSTextAlignmentRight;
    //degree.backgroundColor = [UIColor blackColor];//範囲確認用着色
    [weatherView addSubview:degree];
    
    //度数アイコン表示箇所指定
    CGRect weatherCIcon = CGRectMake(70, 36, 25 , 25);
    weatherCIconView = [[UIImageView alloc]initWithFrame:weatherCIcon];
    NSLog(@"iconView=%@",self.weather.icon);
    //weatherCIconView.backgroundColor = [UIColor blueColor];//範囲確認用着色
    UIImage *weatherCIconImage = [UIImage imageNamed:@"iconC.png"];
    weatherCIconView.image = weatherCIconImage;
    [self.view addSubview:weatherCIconView];

    
    
    //天気アイコン表示箇所指定
    CGRect weatherIcon = CGRectMake(90, 22, 40 , 40);
    weatherIconView = [[UIImageView alloc]initWithFrame:weatherIcon];
    NSLog(@"iconView=%@",self.weather.icon);
    //weatherIconView.backgroundColor = [UIColor blueColor];//範囲確認用着色
    UIImage *weatherIconImage = [UIImage imageNamed:self.weather.icon];
    weatherIconView.image = weatherIconImage;
    [self.view addSubview:weatherIconView];
    
    
    //ステータスバー部分
    CGRect barRect = CGRectMake(0, 0, height, 20);
    UIView *barView = [[UIView alloc]initWithFrame:barRect];
    barView.backgroundColor = [UIColor whiteColor];
    barView.alpha = 0.3;
    [self.view addSubview:barView];
    
    
    /* ここまで */
    
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
    self.device = [UIDevice currentDevice];
    
    // バッテリーの状態変化の検出を有効化します。
    self.device.batteryMonitoringEnabled = YES;
    
    //UIDeviceクラスのbatteryLevelでバッテリーの残量を0～1の値で取得します。
    NSLog(@"batteryLevel:%f",self.device.batteryLevel);
    
    
    //UIDeviceクラスのbatteryStateでバッテリーの状態を取得します。
    
    
    if (self.device.batteryState == (long)UIDeviceBatteryStateUnknown) {
        [self alertViewMethod];
    }
    if (self.device.batteryState == (long)UIDeviceBatteryStateUnplugged) {
        [self alertViewMethod];
    }
    
    if (self.device.batteryState == (long)UIDeviceBatteryStateCharging)
    {
        //UIDeviceBatteryStateCharging:バッテリー充電中。
        NSLog(@"バッテリー充電中");
        
    }
    if (self.device.batteryState == (long)UIDeviceBatteryStateFull)
    {
        //UIDeviceBatteryStateFull:バッテリーフル充電状態
        NSLog(@"バッテリーフル充電状態");
        
        //フル充電になってもエンディングロールを流す
        [self pluged];
    }
    
    
    // バッテリー状態が変化した通知（UIDeviceBatteryStateDidChangeNotification）を受け取ったら、deviceBatteryStateDidChangeNotification関数を呼びます。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
}



// あらかじめ、バッテリー状態の変化通知が届いた時の処理を行うメソッドを準備しておきます。
- (void)deviceBatteryStateDidChangeNotification:(NSNotification*)note
{
    NSLog(@"電源状態が変化しました");
    //先にアプリを起動して、電源を指した時に呼ばれる
    if (self.device.batteryState == (long)UIDeviceBatteryStateCharging) {
        
        //アラートを自動的に閉じる
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        
        [self pluged];
        
    }else if(self.device.batteryState == (long)UIDeviceBatteryStateUnplugged){

        [self unplugMethod];

    }
   
    
}

//電源がさされた時に呼ばれる関数
- (void)pluged{
    
    //カレンダー情報取得
    [self calenderAuth];
    
    //BGMスタート
    [self bgmstart];
    //エンディングロールスタート
    zentai.hidden = NO;
    
    y = 600;
    scrollspeed = -5;
    scrolllimit = -17;
    [self mainloop];
    
    //ボタンを作成
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight){//横向きの時
        [self buttonUpMethodTurned];
        [self buttonDownNethodTurned];
    }else{//縦向きのとき
        [self buttonUpMethod];
        [self buttonDownNethod];
    }
    

}



-(void)mainloop
{
    
    //NStimerが動いていなければ、動かす
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
    
    y += scrollspeed;
    
    zentai.center = CGPointMake(160, y);
    
    if (y < scrolllimit)
    {
        scrollspeed = 0;
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
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {//縦向きになったとき
        UIImage *imageData = [UIImage imageNamed:@"back1.jpg"];
        imageView.image = imageData;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.center = CGPointMake(width/2, height/2);
        imageView.bounds = CGRectMake(0, 0, width, height);
        
        if(!self.buttonUp){
            //たて向き用に作成
            [self buttonUpMethod];
            [self buttonDownNethod];
        }else{
        //ボタンを縦向き用にする
        self.buttonUp.hidden = NO;
        self.buttonDown.hidden = NO;
        self.buttonUpTurned.hidden = YES;
        self.buttonDownTurned.hidden = YES;
        }
        
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
             interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//横向きになったとき
        
        UIImage *imageData2 = [UIImage imageNamed:@"back2.jpg"];
        imageView.image = imageData2;
        imageView.center = CGPointMake(height/2, width/2);
        imageView.bounds = CGRectMake(0, 0, height, width);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        if(!self.buttonUpTurned){
        //ボタンを横向き用に作成
        [self buttonUpMethodTurned];
        [self buttonDownNethodTurned];
        }else{
            self.buttonUpTurned.hidden = NO;
            self.buttonDownTurned.hidden = NO;
            self.buttonUp.hidden = YES;
            self.buttonDown.hidden = YES;
            
        }

    }
}
-(void)bgmstart{
    [self.bgm stop];
    
    [self.bgm setNumberOfLoops:-1];  //繰り返し設定 0が１回、-1がエンドレス
    [self.bgm prepareToPlay];
    [self.bgm play];
    
    
}

//上に動かす
- (void)moveUp:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        
        scrollspeed = -20;
        scrolllimit = -600;
//        [timer invalidate];
//        
//        y -= 10;
//        
//        zentai.center = CGPointMake(160, y);
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        scrollspeed = -5;
        scrolllimit = -17;
  
    }
    
}

//上に動かすボタン
- (void)buttonUpMethod{
    self.buttonUp =[UIButton buttonWithType:UIButtonTypeCustom];
    
    // ボタンの位置を設定
    self.buttonUp.frame = CGRectMake(270, 80, 44, 44);
    
    // キャプションを設定
    [self.buttonUp setBackgroundImage:[UIImage imageNamed:@"arrow2.png"] forState:UIControlStateNormal];
    
//    //ボタンの背景色を入れて角を丸くする
//    [self.buttonUp setBackgroundColor:[UIColor whiteColor]];
    [self.buttonUp setAlpha:0.3];
//    [[self.buttonUp layer] setCornerRadius:3.0];
//    [self.buttonUp setClipsToBounds:YES];
//
    // キャプションに合わせてサイズを設定
    [self.buttonUp sizeToFit];
    
    // ボタンをビューに追加
    [self.view addSubview:self.buttonUp];
    self.buttonUpTurned.hidden = YES; //f.
    self.buttonUp.hidden = NO;
    
    //長押しされた時に呼ばれるメソッド設定
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(moveUp:)];
    
 
    
    // 長押しが認識される時間を設定
    longpress.minimumPressDuration = 0.5;
    
    // 長押し中に動いても許容されるピクセル数を設定
    longpress.allowableMovement = 100;
    
    [self.buttonUp addGestureRecognizer:longpress];
    
    // ボタンがタップされたときに呼ばれるメソッドを設定
//    [self.buttonUp addTarget:self
//                action:@selector(moveUp)
//                forControlEvents:UIControlEventTouchUpInside];
    
//    // ボタンをビューに追加
//    [self.view addSubview:self.buttonUp];
//    self.buttonUpTurned.hidden = YES; //f.
//    self.buttonUp.hidden = NO;
//
}

//下に動かす
- (void)moveDown:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        {
            
            scrollspeed = 10;
            scrolllimit = -600;
//            [timer invalidate];
//    
//            y += 10;
//    
//            zentai.center = CGPointMake(160, y);
        }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        scrollspeed = -5;
        scrolllimit = -17;
    }
}

//下に動かすボタン
- (void)buttonDownNethod{
    self.buttonDown =[UIButton buttonWithType:UIButtonTypeCustom];
    
    // ボタンの位置を設定
    self.buttonDown.frame = CGRectMake(270, 394, 44, 44);
    
    // キャプションを設定
    [self.buttonDown setBackgroundImage:[UIImage imageNamed:@"arrow1.png"]  forState:UIControlStateNormal];
    
    // キャプションに合わせてサイズを設定
    [self.buttonDown sizeToFit];
    
//    //ボタンの背景色を入れて角を丸くする
//    [self.buttonDown setBackgroundColor:[UIColor whiteColor]];
    [self.buttonDown setAlpha:0.3];
//    [[self.buttonDown layer] setCornerRadius:3.0];
//    [self.buttonDown setClipsToBounds:YES];
    
    //長押しした時に呼ばれるメソッド設定
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(moveDown:)];
    
    // ボタンをビューに追加
    [self.view addSubview:self.buttonDown];
    self.buttonDownTurned.hidden = YES; //f.
    self.buttonDown.hidden = NO;
    
    // 長押しが認識される時間を設定
    longpress.minimumPressDuration = 0.5;
    
    // 長押し中に動いても許容されるピクセル数を設定
    longpress.allowableMovement = 100;

    [self.buttonDown addGestureRecognizer:longpress];

//    // ボタンがタップされたときに呼ばれるメソッドを設定
//    [self.buttonDown addTarget:self
//               action:@selector(moveDown)
//     forControlEvents:UIControlEventTouchUpInside];
    
//    // ボタンをビューに追加
//    [self.view addSubview:self.buttonDown];
//    self.buttonDownTurned.hidden = YES; //f.
//    self.buttonDown.hidden = NO;
    
}


//電源が抜かれた時に呼ばれる関数
-(void)unplugMethod{
    //スクロールスピードをリセット
    scrollspeed = 0;
    
    [self.bgm stop];
    zentai.hidden = YES;
    y = 600;
    self.buttonUp.hidden = YES;
    self.buttonDown.hidden =  YES;
    

}


//読み込み失敗時に呼ばれる関数
- (void)alertViewMethod{
    
    NSString *localize = NSLocalizedString(@"key", nil);
    
    alert = [[UIAlertView alloc] initWithTitle:localize
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}
//上に動かすボタン 横向き用
- (void)buttonUpMethodTurned{
    self.buttonUpTurned =[UIButton buttonWithType:UIButtonTypeCustom];
    
    // ボタンの位置を設定
    CGRect screenSize = [[UIScreen mainScreen] bounds];    //スクリーンサイズの取得
    self.buttonUpTurned.frame = CGRectMake(screenSize.size.height-56, 80, 44, 44);//よこむきのばしょにする
    
    // キャプションを設定
    [self.buttonUpTurned setBackgroundImage:[UIImage imageNamed:@"arrow2.png"] forState:UIControlStateNormal];
    
    [self.buttonUpTurned setAlpha:0.3];
    
    // キャプションに合わせてサイズを設定
    [self.buttonUpTurned sizeToFit];
    
    // ボタンをビューに追加
    [self.view addSubview:self.buttonUpTurned];
    self.buttonUp.hidden = YES;
    self.buttonUpTurned.hidden = NO;
    
    //長押しした時に呼ばれるメソッド設定
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(moveUp:)];
    
    // 長押しが認識される時間を設定
    longpress.minimumPressDuration = 0.5;
    
    // 長押し中に動いても許容されるピクセル数を設定
    longpress.allowableMovement = 100;

    [self.buttonUpTurned addGestureRecognizer:longpress];

    
//    // ボタンがタップされたときに呼ばれるメソッドを設定
//    [self.buttonUpTurned addTarget:self
//                      action:@selector(moveUp)
//            forControlEvents:UIControlEventTouchUpInside];
//    
//    // ボタンをビューに追加
//    [self.view addSubview:self.buttonUpTurned];
//    self.buttonUp.hidden = YES;
//    self.buttonUpTurned.hidden = NO;
    
}
//下に動かすボタン 横向き用
- (void)buttonDownNethodTurned{
    self.buttonDownTurned =[UIButton buttonWithType:UIButtonTypeCustom];
    
    // ボタンの位置を設定
    CGRect screenSize = [[UIScreen mainScreen] bounds];    //スクリーンサイズの取得
    self.buttonDownTurned.frame = CGRectMake(screenSize.size.height-56, screenSize.size.width-56, 44, 44);
    
    // キャプションを設定
    [self.buttonDownTurned setBackgroundImage:[UIImage imageNamed:@"arrow1.png"]  forState:UIControlStateNormal];
    
    // キャプションに合わせてサイズを設定
    [self.buttonDownTurned sizeToFit];
    
    [self.buttonDownTurned setAlpha:0.3];
    
    // ボタンをビューに追加
    [self.view addSubview:self.buttonDownTurned];
    self.buttonDown.hidden = YES;
    self.buttonDownTurned.hidden = NO;
    
    //長押しした時に呼ばれるメソッド設定
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(moveDown:)];
    
    // 長押しが認識される時間を設定
    longpress.minimumPressDuration = 0.5;
    
    // 長押し中に動いても許容されるピクセル数を設定
    longpress.allowableMovement = 100;

    [self.buttonDownTurned addGestureRecognizer:longpress];

//    // ボタンがタップされたときに呼ばれるメソッドを設定
//    [self.buttonDownTurned addTarget:self
//                        action:@selector(moveDown)
//              forControlEvents:UIControlEventTouchUpInside];
    
//    // ボタンをビューに追加
//    [self.view addSubview:self.buttonDownTurned];
//    self.buttonDown.hidden = YES;
//    self.buttonDownTurned.hidden = NO;
    
}



@end
