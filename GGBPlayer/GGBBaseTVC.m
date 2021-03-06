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
    artworkButton.imageView.contentMode = UIViewContentModeScaleAspectFill;

    if (@available(iOS 9, *)) {
        [artworkButton.widthAnchor constraintEqualToConstant: CELL_IMAGE_HEIGHT].active = YES;
        [artworkButton.heightAnchor constraintEqualToConstant: CELL_IMAGE_HEIGHT].active = YES;
    }

    UIBarButtonItem *artworkItem = [[UIBarButtonItem alloc] initWithCustomView:artworkButton];
    
    MPMusicPlaybackState playbackState = [GGBLibraryController playbackState];
    
    UIBarButtonSystemItem barButtonSystemItem = (playbackState == MPMusicPlaybackStatePlaying) ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay;
    SEL selector = (playbackState == MPMusicPlaybackStatePlaying) ? @selector(pauseNowPlayingItem) : @selector(playNowPlayingItem);
    
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:barButtonSystemItem
                                                                             target:self
                                                                             action:selector];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil];
    
    UIBarButtonItem *titleBtn = [self titleBtnForNowPlayingItem:nowPlayingItem];
    
    [self setToolbarItems:@[artworkItem, flex, titleBtn, flex, playBtn]];

}

- (UIBarButtonItem *)titleBtnForNowPlayingItem:(MPMediaItem *)nowPlayingItem {
    
    CGFloat toolbarWidth = self.navigationController.toolbar.frame.size.width;
    CGFloat barButtonSystemItemWidth = 44.0;
    CGFloat padding = 22.0;
    CGFloat occupiedWidth = CELL_IMAGE_HEIGHT + barButtonSystemItemWidth + padding * 2;
    CGFloat availableWidth = toolbarWidth - occupiedWidth;

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.titleLabel.numberOfLines = 2;
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    CGFloat defaultFontSize = titleButton.titleLabel.font.pointSize;
    CGFloat fontSize = defaultFontSize - 2;
    
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];

    NSAttributedString *artistString = [self artistAttributedStringFromItem:nowPlayingItem
                                                                       font:font
                                                             availableWidth:availableWidth];
    
    font = [UIFont systemFontOfSize:fontSize];

    NSAttributedString *itemTitleString = [self itemTitleAttributedStringFromItem:nowPlayingItem
                                                                             font:font];
    
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:@""];
    [titleText appendAttributedString:artistString];
    [titleText appendAttributedString:itemTitleString];
    [titleButton setAttributedTitle:titleText
                           forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor blackColor]
                      forState:UIControlStateNormal];
    [titleButton sizeToFit];

    [titleButton addTarget:self
                    action:@selector(showTrackInfo)
          forControlEvents:UIControlEventTouchUpInside];

    CGFloat titleButtonWidth = titleButton.frame.size.width;

    if (titleButtonWidth > availableWidth) {
        titleButton.frame = CGRectMake(titleButton.frame.origin.x, titleButton.frame.origin.y, toolbarWidth - occupiedWidth, titleButton.frame.size.height);
    }

    UIBarButtonItem *titleBtn = [[UIBarButtonItem alloc] initWithCustomView:titleButton];
    
    return titleBtn;
    
}

- (NSAttributedString *)artistAttributedStringFromItem:(MPMediaItem *)nowPlayingItem font:(UIFont *)font availableWidth:(CGFloat)availableWidth{
    
    NSMutableString *albumArtist = nowPlayingItem.albumArtist.mutableCopy;
    NSDictionary *attributes = @{NSFontAttributeName: font};

    NSRange range = {albumArtist.length-1, 1};
    
    while ([albumArtist boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil].size.width > availableWidth) {
        
        [albumArtist deleteCharactersInRange:range];
        range.location--;
        [albumArtist replaceCharactersInRange:range withString:@"…"];
        
    }
    
    NSAttributedString *artistString = [[NSAttributedString alloc] initWithString:[albumArtist stringByAppendingString:@"\n"]
                                                                       attributes:attributes];

    return artistString;
    
}

- (NSAttributedString *)itemTitleAttributedStringFromItem:(MPMediaItem *)nowPlayingItem font:(UIFont *)font {
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    paragrahStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragrahStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName           : font,
                                 NSParagraphStyleAttributeName : paragrahStyle};
    
    NSString *itemTitle = nowPlayingItem.title;
    NSAttributedString *itemTitleString = [[NSAttributedString alloc] initWithString:itemTitle
                                                                          attributes:attributes];
    
    return itemTitleString;

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

- (void)subscribeToNotifications {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(playbackStateDidChange)
               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(nowPlayingItemDidChange)
               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(nowPlayingItemDidChange)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];

}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollToSelectedCell {
    
    // do not work if cell is not visible
    // TODO: have to fix it
    
    if (!self.selectedCell) return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.selectedCell];
    
    if (!indexPath) return;
    
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:NO];

}

- (void)showTrackInfo {
    [self.navigationController performSegueWithIdentifier:@"showTrackInfo" sender:self];
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self refreshNowPlayingItem];
    [self subscribeToNotifications];
    [self scrollToSelectedCell];
    
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
    
    if (!cellImage) {
        cellImage = [UIImage imageNamed:@"cd.png"];
    }
    
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
