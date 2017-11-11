//
//  GGBTrackInfoVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 08/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBTrackInfoVC.h"
#import "GGBLibraryController.h"


@interface GGBTrackInfoVC ()

@property (weak, nonatomic) IBOutlet UIImageView *trackImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UILabel *albumTitle;
@property (weak, nonatomic) IBOutlet UILabel *trackTitle;

@property (weak, nonatomic) IBOutlet UISlider *currentPositionSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentPositionTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTrackTime;

@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;


@end


@implementation GGBTrackInfoVC


#pragma mark - gestures

- (void)addSwipeGesture {
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(dismissSelf)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swipe];

}

- (void)addDoubleTapGesture {
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(likeToCurrentItem)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self.trackImageView addGestureRecognizer:doubleTap];

}


#pragma mark - buttons

- (IBAction)rewindButtonPressed:(id)sender {
}

- (IBAction)playButtonPressed:(id)sender {
    ([GGBLibraryController playbackState] == MPMusicPlaybackStatePlaying) ? [GGBLibraryController pause] : [GGBLibraryController play];
}

- (IBAction)fastForwardButtonPressed:(id)sender {
    [GGBLibraryController next];
}


#pragma mark - fill info

- (void)fillTrackInfo {
    
    MPMediaItem *currentItem = [GGBLibraryController nowPlayingItem];

    [self fillArtworkForItem:currentItem];
    [self fillTitlesForItem:currentItem];
    [self fillDurationForItem:currentItem];
    [self fillRatingForItem:currentItem];
    [self fillPlayPauseButton];
    
}

- (void)fillArtworkForItem:(MPMediaItem *)item {
    
    UIImage *trackImage = [item.artwork imageWithSize:self.trackImageView.frame.size];
    
    if (!trackImage) {
        trackImage = [UIImage imageNamed:@"cd.png"];
    }
    
    self.trackImageView.image = trackImage;

}

- (void)likeToCurrentItem {
    
    MPMediaItem *currentItem = [GGBLibraryController nowPlayingItem];

    NSUInteger newRating = (currentItem.rating == 5) ? 0 : 5;
    
    [currentItem setValue:@(newRating)
                   forKey:MPMediaItemPropertyRating];
    
    [self fillRatingForItem:currentItem];
    
}

- (void)fillTitlesForItem:(MPMediaItem *)item {
    
    self.artistName.text = item.artist;
    self.albumTitle.text = [NSString stringWithFormat:@"(%@) %@", [item valueForProperty:@"year"], item.albumTitle];
    self.trackTitle.text = item.title;

}

- (void)fillDurationForItem:(MPMediaItem *)item {

    NSNumber *duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];

    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    NSString *durationString = [dateComponentsFormatter stringFromTimeInterval:duration.doubleValue];
    
    self.totalTrackTime.text = durationString;
    
}

- (void)fillRatingForItem:(MPMediaItem *)item {
    [self.likeImageView setHighlighted:(item.rating == 5)];
}

- (void)fillPlayPauseButton {
    
    MPMusicPlaybackState playbackState = [GGBLibraryController playbackState];

    NSString *imageName = (playbackState == MPMusicPlaybackStatePlaying) ? @"icons8-pause" : @"icons8-play";
    self.playButton.imageView.image = [UIImage imageNamed:imageName];
    
}


#pragma mark - notifications

- (void)subscribeToPlayerNotifications {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(playbackStateDidChange)
               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(nowPlayingItemDidChange)
               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
             object:nil];
    
}

- (void)unsubscribeFromPlayerNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playbackStateDidChange {
    [self fillPlayPauseButton];
}

- (void)nowPlayingItemDidChange {
    [self fillTrackInfo];
}


#pragma mark - view lifecycle

- (void)dismissSelf {
    
    [self unsubscribeFromPlayerNotifications];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)customInit {

    [self subscribeToPlayerNotifications];
    [self addSwipeGesture];
    [self addDoubleTapGesture];
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
