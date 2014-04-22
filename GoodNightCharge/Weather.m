//
//  Weather.m
//  GoodNightCharge
//
//  Created by bizan.com.mac03 on 2014/04/22.
//  Copyright (c) 2014年 bizan.com.kunren. All rights reserved.
//

#import "Weather.h"

@implementation Weather

//温度取得関数
- (void)takeInfo{
    NSMutableArray *block = [[NSMutableArray alloc]init];
    block = [self.jsonObject objectForKey:@"list"];
    int count = [block count];
    int i;
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit |
                                   NSMonthCalendarUnit  |
                                   NSDayCalendarUnit    |
                                   NSHourCalendarUnit   |
                                   NSMinuteCalendarUnit |
                                   NSSecondCalendarUnit
                                              fromDate:date];
    int thisyear = (int)dateComps.year;
    int thisMonth = (int)dateComps.month;
    int today = (int)dateComps.day;
    NSString *date2;
    if (thisMonth <10) {
        date2 = [NSString stringWithFormat:@"%d-0%d-%d 12:00:00",thisyear,thisMonth,today+1];
    }else{
        date2 = [NSString stringWithFormat:@"%d-%d-%d 12:00:00",thisyear,thisMonth,today+1];
    }
    
    NSDictionary *block2;
    for (i=0; i<count; i++) {
        block2 = [block objectAtIndex:i];
        self.tomorrow = [block2 objectForKey:@"dt_txt"];
        
        //次の日の昼１２時の情報を取得する
        if ([date2 isEqualToString:self.tomorrow]) {
            //気温情報取得
            NSDictionary *main = [block2 objectForKey:@"main"];
            self.temp = [main objectForKey:@"temp"];
            //華氏を摂氏に変換
            double tempInt = self.temp.doubleValue;
            double sesshi =  tempInt - 273.15;
            self.temp = [NSString stringWithFormat:@"%.2f",sesshi];
            NSLog(@"sesshi=%@",self.temp);
            
            //アイコン情報取得
            NSArray *weather = [block2 objectForKey:@"weather"];
            NSDictionary *icon = [weather objectAtIndex:0];
            self.icon = [NSString stringWithFormat:@"%@.png",[icon objectForKey:@"icon"]];
            NSLog(@"icon=%@",self.icon);
            
        }
    }
}




//webAPI通信関数
- (NSDictionary*)webAPIMethod:(NSString*)urlApi{
    self.jsonObject =nil;
    NSLog(@"%@",urlApi);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlApi]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //sendSynchronousRequestメソッドでURLにアクセス
    NSHTTPURLResponse* resp;
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
    
    //通信エラーの際の処理を考える必要がある
    if (resp.statusCode != 200){
        NSDictionary *error = [[NSDictionary alloc]init];
        error = @{@"error":@"error"};
        self.jsonObject = error;
        [self alertViewMethod];
        return self.jsonObject;
    }
    
    //返ってきたデータをJSONObjectWithDataメソッドで解析
    else{
        self.jsonObject = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingAllowFragments error:nil];
        return self.jsonObject;
        
    }
}


//読み込み失敗時に呼ばれる関数
- (void)alertViewMethod{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"connection failed"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}


@end
