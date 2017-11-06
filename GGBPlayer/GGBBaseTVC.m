//
//  GGBBaseTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 05/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBBaseTVC.h"


@interface GGBBaseTVC ()

@end

@implementation GGBBaseTVC

- (void)refreshNowPlayingItem {
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    if (!nowPlayingItem) return;
    
    UIImage *buttonImage = [nowPlayingItem.artwork imageWithSize:CGSizeMake(CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT)];
    UIButton *artworkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [artworkButton setImage:buttonImage
                   forState:UIControlStateNormal];
    artworkButton.frame = CGRectMake(0, 0, CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT);
    UIBarButtonItem *artworkItem = [[UIBarButtonItem alloc] initWithCustomView:artworkButton];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.titleLabel.numberOfLines = 0;
    
    CGFloat defaultFontSize = titleButton.titleLabel.font.pointSize;
    CGFloat fontSize = defaultFontSize - 2;
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]};
    NSAttributedString *artistString = [[NSAttributedString alloc] initWithString:[nowPlayingItem.albumArtist stringByAppendingString:@"\n"]
                                                                       attributes:attribute];
    attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    NSAttributedString *itemTitleString = [[NSAttributedString alloc] initWithString:nowPlayingItem.title
                                                                          attributes:attribute];
    
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:@""];
    [titleText appendAttributedString:artistString];
    [titleText appendAttributedString:itemTitleString];
    [titleButton setAttributedTitle:titleText
                           forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor blackColor]
                      forState:UIControlStateNormal];
    [titleButton sizeToFit];
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIBarButtonItem *titleBtn = [[UIBarButtonItem alloc] initWithCustomView:titleButton];
    
    MPMusicPlaybackState playbackState = [GGBLibraryController playbackState];
    
    UIBarButtonSystemItem barButtonSystemItem = (playbackState == MPMusicPlaybackStatePlaying) ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay;
    SEL selector = (playbackState == MPMusicPlaybackStatePlaying) ? @selector(pauseNowPlayingItem) : @selector(playNowPlayingItem);
    
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:barButtonSystemItem
                                                                             target:self
                                                                             action:selector];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:selector];
    
    [self setToolbarItems:@[artworkItem, flex, titleBtn, flex, playBtn]];
    
}

- (void)playNowPlayingItem {
    [GGBLibraryController play];
}

- (void)pauseNowPlayingItem {
    [GGBLibraryController pause];
}

- (void)playbackStateDidChange {
    
    [self refreshNowPlayingItem];
    [self reloadSelectedCell];

}

- (void)nowPlayingItemDidChange {
    
    [self refreshNowPlayingItem];
    [self reloadSelectedCell];
    [self reloadNowPlayingCell];

}

- (void)reloadSelectedCell {
    
    if (!self.selectedCell) return;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:self.selectedCell];
    
    if (!selectedIndexPath) return;
    [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)reloadNowPlayingCell {
    
    NSPredicate *nowPlayingPredicate = [self nowPlayingPredicate];
    self.selectedCell = nowPlayingPredicate ? [self.tableView.visibleCells filteredArrayUsingPredicate:nowPlayingPredicate].firstObject : self.tableView.visibleCells.firstObject;
    [self reloadSelectedCell];
    
}

- (NSPredicate *)nowPlayingPredicate {
    return nil;
}

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

- (void)customInit {
    
    [self refreshNowPlayingItem];
    [self subscribeToPlayerNotifications];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)setImage:(UIImage *)cellImage forCell:(UITableViewCell *)cell {
    
    cell.imageView.image = cellImage;
    
    CGFloat widthScale = CELL_IMAGE_HEIGHT / cellImage.size.width;
    CGFloat heightScale = CELL_IMAGE_HEIGHT / cellImage.size.height;
    
    cell.imageView.transform = CGAffineTransformMakeScale(widthScale, heightScale);

}

- (void)selectCell:(UITableViewCell *)cell {
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.selectedCell = cell;

}

- (void)unselectCell:(UITableViewCell *)cell {

    cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    cell.backgroundColor = [UIColor whiteColor];

}


@end
