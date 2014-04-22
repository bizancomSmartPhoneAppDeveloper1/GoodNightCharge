//
//  ViewController.h
//  GoodNightCharge
//
//  Created by bizan.com.mac03 on 2014/04/22.
//  Copyright (c) 2014年 bizan.com.kunren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Weather.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate>
{
}

@property (nonatomic, retain) CLLocationManager *locationManager;//現在地情報を格納するCLLocationManagerクラスのインスタンス}
@property double longitude;
@property double latitude;
@property NSURL *url;

@property Weather *weather;
@property AVAudioPlayer *bgm;
@property BOOL pawerstatus;



@end
