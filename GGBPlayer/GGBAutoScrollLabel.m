//
//  GGBAutoScrollLabel.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 09/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBAutoScrollLabel.h"

@interface GGBAutoScrollLabel()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) NSTimer *timer;


@end


@implementation GGBAutoScrollLabel

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self initSelfWithFrame:self.frame];
    
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelfWithFrame:frame];
    }
    return self;
    
}

- (void)initSelfWithFrame:(CGRect)frame {
    
    self.clipsToBounds = YES;
    self.autoresizesSubviews = YES;
    
    [self initTextLabelWithFrame:frame];

}

- (void)initTextLabelWithFrame:(CGRect)frame {
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.textLabel];

}

- (void)setLabelText:(NSString *)text {
    
    self.textLabel.text  = text;
    NSDictionary *attributes = @{NSFontAttributeName: self.textLabel.font};
    CGSize textSize = [text sizeWithAttributes:attributes];
    
    if (textSize.width > self.frame.size.width) {
        self.textLabel.frame = CGRectMake(0, 0, textSize.width, self.frame.size.height);
    } else {
        self.textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    
    [self flushTimer];

    if (self.textLabel.frame.size.width > self.frame.size.width) {
        [self initTimer];
    }
    
}

- (void)initTimer {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(moveText)
                                                userInfo:nil
                                                 repeats:YES];

}

- (void)flushTimer {
    
    [self.timer invalidate];
    self.timer = nil;

}

- (void)moveText {
    
    if (self.textLabel.frame.origin.x < self.textLabel.frame.size.width - 2 * self.textLabel.frame.size.width) {
        
        CGRect frame = self.textLabel.frame;
        frame.origin.x = self.frame.size.width;
        self.textLabel.frame = frame;
        
    }
    
    [UIView beginAnimations:nil
                    context:nil];
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x -= 5;
    self.textLabel.frame = frame;
    [UIView commitAnimations];
    
}

- (UIFont *)labelFont {
    return self.textLabel.font;
}

- (void)setLabelFont:(UIFont *)font {
    self.textLabel.font = font;
}

- (void)setLabelTextColor:(UIColor *)color {
    self.textLabel.textColor = color;
}

- (void)setLabelTextAlignment:(NSTextAlignment)alignment {
    self.textLabel.textAlignment = alignment;
}


@end
