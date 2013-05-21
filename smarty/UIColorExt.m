//
//  UIColorExt.m
//

#import "UIColorExt.h"

@implementation UIColor (UIColorExt)

// Product Colors
// 
// Color       Hex     Dec
// ----------- ------- -----------
// monthTeal  #3579DC  53 121  220


+ (UIColor*)monthGridTealColor {
    return [UIColor colorWithRed:53.0/255.0 green:121.0/255.0 blue:220.0/255.0 alpha:1.0];
}

+ (UIColor*)grey2Color {
    return [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
}

+ (UIColor*)grey5Color {
    return [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
}

+ (UIColor*)veryLightBlueColor {
    return [UIColor colorWithRed:217.0/255.0 green:224.0/255.0 blue:230.0/255.0 alpha:1.0];
}

+ (UIColor*)lightBlueColor {
    return [UIColor colorWithRed:0 green:148.0/255.0 blue:180.0/255.0 alpha:1.0];
}


@end
