//
//  GGBBaseTracksTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 06/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBBaseTracksTVC.h"

@interface GGBBaseTracksTVC ()

@end

@implementation GGBBaseTracksTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withMediaItem:(MPMediaItem *)item {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"
                                                            forIndexPath:indexPath];
    
    NSString *trackTitle = item.title;
    NSUInteger rating = item.rating;
    NSString *ratingString = @"";
    
    for (int i=0; i<5; i++) {
        
        if (i < rating) {
            ratingString = [ratingString stringByAppendingString:@"★"];
        } else {
            ratingString = [ratingString stringByAppendingString:@"☆"];
        }
        
    }
    
    cell.textLabel.text = trackTitle;
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    if ([nowPlayingItem.albumArtist isEqualToString:item.albumArtist] &&
        [nowPlayingItem.albumTitle isEqualToString:item.albumTitle] &&
        [nowPlayingItem.title isEqualToString:item.title]) {
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        self.selectedCell = cell;
        
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    }
    
    cell.detailTextLabel.text = ratingString;
    cell.tag = item.albumTrackNumber;
    
    [super setImage:[item.artwork imageWithSize:CGSizeMake(CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT)]
            forCell:cell];
    
    return cell;
    
}


#pragma mark - Notifications

- (NSPredicate *)nowPlayingPredicate {
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    NSPredicate *nowPlayingPredicate = [NSPredicate predicateWithFormat:@"textLabel.text == %@ && tag == %@", nowPlayingItem.title, @(nowPlayingItem.albumTrackNumber)];
    
    return nowPlayingPredicate;
    
}


@end
