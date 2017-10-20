//
//  GGBAllTracksTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 20/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBAllTracksTVC.h"
#import "GGBLibraryController.h"


@interface GGBAllTracksTVC ()

@property (nonatomic, strong) NSArray <MPMediaItemCollection *> *collections;


@end


@implementation GGBAllTracksTVC

- (void)customInit {
    
    self.collections = [GGBLibraryController collectionsFilteredByAlbumArtist:self.albumArtist];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"representativeItem.year"
                                                                     ascending:YES
                                                                      selector:@selector(compare:)];
    
    self.collections = [self.collections sortedArrayUsingDescriptors:@[sortDescriptor]];

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
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
    cell.detailTextLabel.text = ratingString;
    
    cell.imageView.image = [item.artwork imageWithSize:cell.imageView.image.size];
    
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


@end