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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
