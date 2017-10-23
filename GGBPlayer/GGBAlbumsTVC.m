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
#import "GGBAllTracksTVC.h"
#import "GGBConstants.h"


@interface GGBAlbumsTVC ()

@end


@implementation GGBAlbumsTVC

- (void)customInit {
    
    self.title = self.albumArtist;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"year"
                                                                     ascending:YES
                                                                      selector:@selector(compare:)];
    
    self.albumsInfo = [self.albumsInfo sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    UIBarButtonItem *allTracksButton = [[UIBarButtonItem alloc] initWithTitle:@"All tracks"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(showAllTracks)];
    self.navigationItem.rightBarButtonItem = allTracksButton;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showAllTracks {
    
    [self performSegueWithIdentifier:@"showAllTracks"
                              sender:self];
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

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
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];
    
    if ([nowPlayingItem.albumArtist isEqualToString:mediaItem.albumArtist] &&
        [nowPlayingItem.albumTitle isEqualToString:mediaItem.albumTitle]) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"tracks: %@", albumTrackCount];
    
    cell.imageView.image = [mediaItem.artwork imageWithSize:CGSizeMake(CELL_HEIGHT, CELL_HEIGHT)];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showTracks" sender:indexPath];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showAllTracks"]) {
        [self prepareForShowAllTracksSegue:segue sender:sender];
    }

    if ([segue.identifier isEqualToString:@"showTracks"]) {
        [self prepareForShowTracksSegue:segue sender:sender];
    }
    
}

- (void)prepareForShowAllTracksSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (![segue.identifier isEqualToString:@"showAllTracks"]) return;
    if (![segue.destinationViewController isKindOfClass:[GGBAllTracksTVC class]]) return;
    
    GGBAllTracksTVC *allTracksTVC = (GGBAllTracksTVC *)segue.destinationViewController;
    allTracksTVC.albumArtist = self.albumArtist;

}

- (void)prepareForShowTracksSegue:(UIStoryboardSegue *)segue sender:(id)sender {

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
