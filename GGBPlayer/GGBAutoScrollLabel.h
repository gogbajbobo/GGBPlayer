//
//  GGBAutoScrollLabel.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 09/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGBAutoScrollLabel : UIView

@property (nonatomic, strong) NSString * labelText;
@property (nonatomic, strong) UIFont * labelFont;
@property (nonatomic, strong) UIColor * labelTextColor;
@property (nonatomic) NSTextAlignment labelTextAlignment;


@end
