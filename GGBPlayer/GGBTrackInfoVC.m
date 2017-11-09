//
//  GGBTrackInfoVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 08/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBTrackInfoVC.h"
#import "GGBLibraryController.h"
#import "GGBAutoScrollLabel.h"


@interface GGBTrackInfoVC ()

@property (weak, nonatomic) IBOutlet UIImageView *trackImageView;
@property (weak, nonatomic) IBOutlet GGBAutoScrollLabel *artistLabel;
@property (weak, nonatomic) IBOutlet GGBAutoScrollLabel *trackTitleLabel;


@end


@implementation GGBTrackInfoVC

- (void)dismissSelf {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)addSwipeGesture {
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(dismissSelf)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swipe];

}

- (void)fillTrackInfo {
    
    MPMediaItem *currentItem = [GGBLibraryController nowPlayingItem];
    
    UIImage *trackImage = [currentItem.artwork imageWithSize:self.trackImageView.frame.size];
    
    if (!trackImage) {
        trackImage = [UIImage imageNamed:@"cd.png"];
    }

    self.trackImageView.image = trackImage;
    
    self.artistLabel.labelText = currentItem.artist;
    self.artistLabel.labelFont = [UIFont boldSystemFontOfSize:self.artistLabel.labelFont.pointSize];
    self.trackTitleLabel.labelText = currentItem.title;
    
}


#pragma mark - view lifecycle

- (void)customInit {

    [self addSwipeGesture];
    [self fillTrackInfo];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
