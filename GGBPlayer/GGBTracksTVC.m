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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [GGBLibraryController numberOfTracksForAlbumTitle:self.albumInfo.albumTitle
                                              andAlbumArtist:self.albumInfo.albumArtist].integerValue;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItem *item = self.collection.items[indexPath.row];
    return [super tableView:tableView cellForRowAtIndexPath:indexPath withMediaItem:item];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSRange subarrayRange = NSMakeRange(indexPath.row, self.collection.count - indexPath.row);
    NSArray *items = [self.collection.items subarrayWithRange:subarrayRange];
    [GGBLibraryController playCollection:[MPMediaItemCollection collectionWithItems:items]];
    
}


@end
