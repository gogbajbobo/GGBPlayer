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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.collections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    MPMediaItemCollection *collection = self.collections[section];
    MPMediaItem *mediaItem = collection.representativeItem;
    NSNumber *year = [mediaItem valueForProperty:@"year"];

    return [NSString stringWithFormat:@"(%@) %@", year, mediaItem.albumTitle];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
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

- (MPMediaItem *)mediaItemForIndexPath:(NSIndexPath *)indexPath {
    return self.collections[indexPath.section].items[indexPath.row];
}

- (NSIndexPath *)indexPathForMediaItem:(MPMediaItem *)item {
    
    __block NSIndexPath *indexPath = nil;
    
    [self.collections enumerateObjectsUsingBlock:^(MPMediaItemCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSUInteger index = [collection.items indexOfObject:item];
        
        if (index != NSNotFound) {
            
            indexPath = [NSIndexPath indexPathForRow:index inSection:idx];
            *stop = YES;
            
        }

    }];
    
    return indexPath;
    
}


@end
