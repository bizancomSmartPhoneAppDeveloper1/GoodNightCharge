//
//  Weather.h
//  GoodNightCharge
//
//  Created by bizan.com.mac03 on 2014/04/22.
//  Copyright (c) 2014年 bizan.com.kunren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Weather : NSObject

@property NSString *temp;
@property NSString *icon;
@property NSDictionary *jsonObject;
@property NSString* tomorrow;

- (void)takeInfo;
- (void)alertViewMethod;
- (NSDictionary*)webAPIMethod:(NSString*)urlApi;


@end
