//
//  GGBAlbumsTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBAlbumsTVC.h"
#import "GGBLibraryController.h"
#import "GGBTracksTVC.h"


@interface GGBAlbumsTVC ()

@end


@implementation GGBAlbumsTVC

- (void)customInit {
    
    self.title = self.albumArtist;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"year"
                                                                     ascending:YES
                                                                      selector:@selector(compare:)];
    
    self.albumsInfo = [self.albumsInfo sortedArrayUsingDescriptors:@[sortDescriptor]];
    
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
    return [GGBLibraryController numberOfAlbumsForAlbumArtist:self.albumArtist].integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    MPMediaItem *mediaItem = self.albumsInfo[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"
                                                            forIndexPath:indexPath];
    
    NSNumber *year = [mediaItem valueForKey:@"year"];
    NSString *albumTitle = mediaItem.albumTitle;
    NSNumber *albumTrackCount = [GGBLibraryController numberOfTracksForAlbumTitle:albumTitle
                                                                   andAlbumArtist:self.albumArtist];
    
    cell.textLabel.text = [NSString stringWithFormat:@"(%@) %@", year, albumTitle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"tracks: %@", albumTrackCount];
    
    cell.imageView.image = [mediaItem.artwork imageWithSize:cell.imageView.image.size];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showTracks" sender:indexPath];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if (![segue.identifier isEqualToString:@"showTracks"]) return;
    if (![segue.destinationViewController isKindOfClass:[GGBTracksTVC class]]) return;
    if (![sender isKindOfClass:[NSIndexPath class]]) return;
    
    GGBTracksTVC *tracksTVC = (GGBTracksTVC *)segue.destinationViewController;
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    
    MPMediaItem *mediaItem = self.albumsInfo[indexPath.row];
    NSString *albumTitle = mediaItem.albumTitle;
    NSString *albumArtist = mediaItem.albumArtist;

    tracksTVC.albumInfo = mediaItem;
    tracksTVC.collection = [GGBLibraryController collectionForAlbumTitle:albumTitle
                                                          andAlbumArtist:albumArtist];
    
}


@end
