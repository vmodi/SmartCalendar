//
//  WeatherForecast.m
//  smarty
//

#import "WeatherForecast.h"
#import "AFJSONRequestOperation.h"
#import "AppConfig.h"

static NSString * const kWeatherBaseUrl  = @"http://api.wunderground.com/api/%@/forecast/q/%@/%@.json";

@implementation WeatherForecast
-(void) getForcastForCity:(NSString*)city State:(NSString*)state{
    
    NSString *apiCall = [NSString stringWithFormat:kWeatherBaseUrl, kWunderGroundApiKey, state, city];
    
    NSURL *url = [NSURL URLWithString:apiCall];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"returned response: %@", [JSON description]);
    } failure:nil];
    
//    [operation start];
}
@end
