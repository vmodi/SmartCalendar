//
//  WeatherForecast.h
//  smarty
//
//  Created by Vishal Modi on 3/6/13.
//  Copyright (c) 2013 vm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherForecast : NSObject
-(void) getForcastForCity:(NSString*)city State:(NSString*)state;
@end
