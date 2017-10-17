//
//  GGBAlbumArtistsTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBArtistsTVC.h"
#import "GGBLibraryController.h"
#import "GGBAlbumsTVC.h"


@interface GGBArtistsTVC ()

@end


@implementation GGBArtistsTVC

- (void)customInit {
    [GGBLibraryController start];
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
    return [GGBLibraryController albumArtists].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *albumArtist = [GGBLibraryController albumArtists][indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumArtistCell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = albumArtist;
    
    NSNumber *numberOfAlbums = [GGBLibraryController numberOfAlbumsForAlbumArtist:albumArtist];
    NSNumber *numberOfTracks = [GGBLibraryController numberOfTracksForAlbumArtist:albumArtist];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"albums: %@, tracks: %@", numberOfAlbums, numberOfTracks];
    
    if (numberOfTracks.integerValue) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.imageView.image = [UIImage imageNamed:@"icons8-Music-512.png"];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showAlbum"
                              sender:indexPath];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if (![segue.identifier isEqualToString:@"showAlbum"]) return;
    if (![segue.destinationViewController isKindOfClass:[GGBAlbumsTVC class]]) return;
    if (![sender isKindOfClass:[NSIndexPath class]]) return;

    GGBAlbumsTVC *albumTVC = (GGBAlbumsTVC *)segue.destinationViewController;
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    NSString *albumArtist = [GGBLibraryController albumArtists][indexPath.row];
    albumTVC.albumArtist = albumArtist;
    albumTVC.albumsInfo = [GGBLibraryController albumsInfoForAlbumArtist:albumArtist];
    
}


@end
