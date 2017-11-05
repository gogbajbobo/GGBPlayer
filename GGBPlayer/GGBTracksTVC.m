//
//  GGBTracksTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBTracksTVC.h"


@interface GGBTracksTVC ()

@end

@implementation GGBTracksTVC

- (void)customInit {
    
    [super customInit];
    
    self.title = [NSString stringWithFormat:@"%@ %@ %@", self.albumInfo.albumArtist, [self.albumInfo valueForKey:@"year"], self.albumInfo.albumTitle];
    
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [GGBLibraryController numberOfTracksForAlbumTitle:self.albumInfo.albumTitle
                                              andAlbumArtist:self.albumInfo.albumArtist].integerValue;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItem *item = self.collection.items[indexPath.row];
    
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
    
    cell.imageView.image = [item.artwork imageWithSize:CGSizeMake(CELL_HEIGHT, CELL_HEIGHT)];
    
    cell.tag = item.albumTrackNumber;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSRange subarrayRange = NSMakeRange(indexPath.row, self.collection.count - indexPath.row);
    NSArray *items = [self.collection.items subarrayWithRange:subarrayRange];
    [GGBLibraryController playCollection:[MPMediaItemCollection collectionWithItems:items]];
    
}


#pragma mark - Notifications

- (NSPredicate *)nowPlayingPredicate {
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    NSPredicate *nowPlayingPredicate = [NSPredicate predicateWithFormat:@"textLabel.text == %@ && tag == %@", nowPlayingItem.title, @(nowPlayingItem.albumTrackNumber)];
    
    return nowPlayingPredicate;
    
}



@end
