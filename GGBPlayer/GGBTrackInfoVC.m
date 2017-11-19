//
//  GGBTrackInfoVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 08/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBTrackInfoVC.h"


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

@property (weak, nonatomic) IBOutlet UIView *volumeSliderView;

@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;

@property (nonatomic, strong) NSTimer *playingTimer;

@property (nonatomic, strong) MPMediaItem *currentItem;


@end


@implementation GGBTrackInfoVC


#pragma mark - variables setters and getters

- (MPMediaItem *)currentItem {

    if (!_currentItem) {
        _currentItem = self.mediaItem ? self.mediaItem : [GGBLibraryController nowPlayingItem];
    }
    return _currentItem;
    
}


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
    ([GGBLibraryController currentPosition] < 1) ? [GGBLibraryController previous] : [GGBLibraryController beginning];
}

- (IBAction)playButtonPressed:(id)sender {
    ([GGBLibraryController playbackState] == MPMusicPlaybackStatePlaying) ? [GGBLibraryController pause] : [GGBLibraryController play];
}

- (IBAction)fastForwardButtonPressed:(id)sender {
    [GGBLibraryController next];
}

- (IBAction)currentPositionChanged:(id)sender {
    
    if (![sender isEqual:self.currentPositionSlider]) return;
    
    NSNumber *duration = [self.currentItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    NSTimeInterval newPosition = self.currentPositionSlider.value * duration.doubleValue;
    
    [GGBLibraryController setCurrentPosition:newPosition];
    [self fillCurrentPosition];
    
}


#pragma mark - fill info

- (void)setupSliders {

    [self setupPositionSlider];
    [self setupVolumeSlider];

}

- (void)setupPositionSlider {
    
    if (self.mediaItem) {
        
        self.currentPositionSlider.hidden = YES;
        return;
        
    }
    
    [self.currentPositionSlider setThumbImage:[UIImage imageNamed:@"transparent"]
                                     forState:UIControlStateNormal];
    
    self.currentPositionSlider.continuous = NO;

}

- (void)setupVolumeSlider {

    if (self.mediaItem) {
        
        self.volumeSliderView.hidden = YES;
        return;
        
    }

    [self.volumeSliderView setNeedsLayout];
    [self.volumeSliderView layoutIfNeeded];
    
    self.volumeSliderView.backgroundColor = [UIColor clearColor];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:self.volumeSliderView.bounds];
    
    [self.volumeSliderView addSubview:volumeView];
    
}

- (void)fillTrackInfo {
    
    [self fillArtworkForItem:self.currentItem];
    [self fillTitlesForItem:self.currentItem];
    [self fillDurationForItem:self.currentItem];
    [self fillRatingForItem:self.currentItem];
    [self fillPlayPauseButton];
    [self fillCurrentPosition];
    [self checkTimerForCurrentPosition];

}

- (void)fillArtworkForItem:(MPMediaItem *)item {
    
    UIImage *trackImage = [item.artwork imageWithSize:self.trackImageView.frame.size];
    
    if (!trackImage) {
        trackImage = [UIImage imageNamed:@"cd.png"];
    }
    
    self.trackImageView.image = trackImage;

}

- (void)likeToCurrentItem {
    
    NSUInteger newRating = (self.currentItem.rating == 5) ? 0 : 5;
    
    [self.currentItem setValue:@(newRating)
                   forKey:MPMediaItemPropertyRating];
    
    [self fillRatingForItem:self.currentItem];
    
}

- (void)fillTitlesForItem:(MPMediaItem *)item {
    
    self.artistName.text = item.artist;
    self.albumTitle.text = [NSString stringWithFormat:@"(%@) %@", [item valueForProperty:@"year"], item.albumTitle];
    self.trackTitle.text = item.title;

}

- (void)fillDurationForItem:(MPMediaItem *)item {

    if (self.mediaItem) {
        
        self.totalTrackTime.hidden = YES;
        return;
        
    }
    
    NSNumber *duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];

    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSString *durationString = [dateComponentsFormatter stringFromTimeInterval:duration.doubleValue];
    
    self.totalTrackTime.text = durationString;
    
}

- (void)fillRatingForItem:(MPMediaItem *)item {
    [self.likeImageView setHighlighted:(item.rating == 5)];
}

- (void)fillPlayPauseButton {
    
    if (self.mediaItem) {
        
        self.playButton.hidden = YES;
        self.rewindButton.hidden = YES;
        self.fastForwardButton.hidden = YES;
        return;
        
    }

    MPMusicPlaybackState playbackState = [GGBLibraryController playbackState];

    NSString *imageName = (playbackState == MPMusicPlaybackStatePlaying) ? @"icons8-pause" : @"icons8-play";
    self.playButton.imageView.image = [UIImage imageNamed:imageName];
    
}

- (void)checkTimerForCurrentPosition {
    
    if (self.mediaItem) return;
    
    MPMusicPlaybackState playbackState = [GGBLibraryController playbackState];

    if (playbackState == MPMusicPlaybackStatePlaying) {
        
        [self initPlayingTimer];
        
    } else {
        
        [self invalidatePlayingTimer];
        [self fillCurrentPosition];
        
    }

}

- (void)initPlayingTimer {
    
    [self invalidatePlayingTimer];
    
    self.playingTimer = [NSTimer timerWithTimeInterval:1
                                                target:self
                                              selector:@selector(fillCurrentPosition)
                                              userInfo:nil
                                               repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.playingTimer
                                 forMode:NSDefaultRunLoopMode];
    
}

- (void)invalidatePlayingTimer {
    
    [self.playingTimer invalidate];
    self.playingTimer = nil;
    
}

- (void)fillCurrentPosition {
    
    if (self.mediaItem) {
        
        self.currentPositionTime.hidden = YES;
        self.currentPositionSlider.hidden = YES;
        return;
        
    }
    
    NSTimeInterval currentPosition = [GGBLibraryController currentPosition];
    
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSString *currentPositionString = [dateComponentsFormatter stringFromTimeInterval:currentPosition];

    self.currentPositionTime.text = currentPositionString;
    
    NSNumber *duration = [self.currentItem valueForProperty:MPMediaItemPropertyPlaybackDuration];

    float sliderValue = currentPosition / duration.doubleValue;
    self.currentPositionSlider.value = sliderValue;
    
}


#pragma mark - notifications

- (void)subscribeToPlayerNotifications {
    
    if (self.mediaItem) return;
    
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
    [self checkTimerForCurrentPosition];
    
}

- (void)nowPlayingItemDidChange {
    
    [self fillTrackInfo];
    [self fillCurrentPosition];
    
}


#pragma mark - view lifecycle

- (void)dismissSelf {
    
    [self unsubscribeFromPlayerNotifications];
    [self invalidatePlayingTimer];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)customInit {

    [self subscribeToPlayerNotifications];
    [self addSwipeGesture];
    [self addDoubleTapGesture];
    [self setupSliders];
    [self fillTrackInfo];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
