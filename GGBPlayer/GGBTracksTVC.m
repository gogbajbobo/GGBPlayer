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
    
    self.title = [NSString stringWithFormat:@"%@ %@ %@", self.albumInfo.albumArtist, [self.albumInfo valueForKey:@"year"], self.albumInfo.albumTitle];
    
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
    cell.detailTextLabel.text = ratingString;
    
    cell.imageView.image = [item.artwork imageWithSize:cell.imageView.image.size];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSRange subarrayRange = NSMakeRange(indexPath.row, self.collection.count - indexPath.row);
    NSArray *items = [self.collection.items subarrayWithRange:subarrayRange];
    [GGBLibraryController playCollection:[MPMediaItemCollection collectionWithItems:items]];
    
}


@end
