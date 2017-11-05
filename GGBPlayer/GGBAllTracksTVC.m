//
//  GGBAllTracksTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 20/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBAllTracksTVC.h"


@interface GGBAllTracksTVC ()

@property (nonatomic, strong) NSArray <MPMediaItemCollection *> *collections;


@end


@implementation GGBAllTracksTVC

- (void)customInit {

    [super customInit];
    
    self.collections = [GGBLibraryController collectionsFilteredByAlbumArtist:self.albumArtist];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"representativeItem.year"
                                                                     ascending:YES
                                                                      selector:@selector(compare:)];
    
    self.collections = [self.collections sortedArrayUsingDescriptors:@[sortDescriptor]];

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
    return self.collections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    MPMediaItemCollection *collection = self.collections[section];
    MPMediaItem *mediaItem = collection.representativeItem;
    NSNumber *year = [mediaItem valueForKey:@"year"];

    return [NSString stringWithFormat:@"(%@) %@", year, mediaItem.albumTitle];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MPMediaItem *item = self.collections[indexPath.section].items[indexPath.row];
    
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
        
        UIImageView *iView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons8-Play-100.png"]];
        iView.frame = CGRectMake(0, 0, CELL_HEIGHT, CELL_HEIGHT);
        cell.accessoryView = iView;
        
        self.selectedCell = cell;
        
    } else {
        
        cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
        cell.accessoryView = nil;
        
    }

    cell.detailTextLabel.text = ratingString;
    cell.imageView.image = [item.artwork imageWithSize:CGSizeMake(CELL_HEIGHT, CELL_HEIGHT)];
    cell.tag = item.albumTrackNumber;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItemCollection *selectedCollection = self.collections[indexPath.section];
    
    NSRange subarrayRange = NSMakeRange(indexPath.row, selectedCollection.count - indexPath.row);
    NSArray *items = [selectedCollection.items subarrayWithRange:subarrayRange];
    
    for (NSInteger i = indexPath.section + 1; i < self.collections.count; i++) {
        items = [items arrayByAddingObjectsFromArray:self.collections[i].items];
    }
    
    [GGBLibraryController playCollection:[MPMediaItemCollection collectionWithItems:items]];
    
}


#pragma mark - Notifications

- (NSPredicate *)nowPlayingPredicate {
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    NSPredicate *nowPlayingPredicate = [NSPredicate predicateWithFormat:@"textLabel.text == %@ && tag == %@", nowPlayingItem.title, @(nowPlayingItem.albumTrackNumber)];
    
    return nowPlayingPredicate;
    
}


@end
