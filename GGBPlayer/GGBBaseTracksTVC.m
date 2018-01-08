//
//  GGBBaseTracksTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 06/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBBaseTracksTVC.h"

#import "GGBTrackInfoVC.h"


@interface GGBBaseTracksTVC () <UIGestureRecognizerDelegate>


@end


@implementation GGBBaseTracksTVC


#pragma mark - view lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self addLongPress];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItem *item = [self mediaItemForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"
                                                            forIndexPath:indexPath];
    
    NSString *trackTitle = item.title;
    cell.textLabel.text = trackTitle;
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    if ([nowPlayingItem.albumArtist isEqualToString:item.albumArtist] &&
        [nowPlayingItem.albumTitle isEqualToString:item.albumTitle] &&
        [nowPlayingItem.title isEqualToString:item.title]) {
        [super selectCell:cell];
    } else {
        [super unselectCell:cell];
    }
    
    NSUInteger rating = item.rating;
    NSString *ratingString = @"";
    
    for (int i=0; i<5; i++) {
        
        if (i < rating) {
            ratingString = [ratingString stringByAppendingString:@"★"];
        } else {
            ratingString = [ratingString stringByAppendingString:@"☆"];
        }
        
    }
    
    NSString *detailText = ratingString;
    
    if (![item.albumArtist isEqualToString:item.artist]) {
        detailText = [[detailText stringByAppendingString:@" "] stringByAppendingString:item.artist];
    }

    cell.detailTextLabel.text = detailText;

    cell.tag = item.albumTrackNumber;
    
    [super setImage:[item.artwork imageWithSize:CGSizeMake(CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT)]
            forCell:cell];
    
    return cell;
    
}

- (MPMediaItem *)mediaItemForIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark - Notifications

- (void)subscribeToNotifications {
    
    [super subscribeToNotifications];
    
}

- (NSPredicate *)nowPlayingPredicate {
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    NSPredicate *nowPlayingPredicate = [NSPredicate predicateWithFormat:@"textLabel.text == %@ && tag == %@", nowPlayingItem.title, @(nowPlayingItem.albumTrackNumber)];
    
    return nowPlayingPredicate;
    
}


#pragma mark - gestures

- (void)addLongPress {

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0; //seconds
    longPress.delegate = self;
    [self.tableView addGestureRecognizer:longPress];

}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        
        if (!indexPath) return;

        MPMediaItem *item = [self mediaItemForIndexPath:indexPath];
        
        [self performSegueWithIdentifier:@"showTrackInfo"
                                  sender:item];

    }
    
}


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (![segue.identifier isEqualToString:@"showTrackInfo"]) return;
    if (![segue.destinationViewController isKindOfClass:[GGBTrackInfoVC class]]) return;
    if (![sender isKindOfClass:[MPMediaItem class]]) return;
    
    GGBTrackInfoVC *trackInfoVC = (GGBTrackInfoVC *)segue.destinationViewController;
    MPMediaItem *item = (MPMediaItem *)sender;
    
    trackInfoVC.mediaItem = item;
    
}



@end
