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
#import "GGBConstants.h"


@interface GGBArtistsTVC ()

@end


@implementation GGBArtistsTVC

- (void)customInit {
    
    MPMediaItem *nowPlayingItem = [GGBLibraryController nowPlayingItem];

    UIImage *buttonImage = [nowPlayingItem.artwork imageWithSize:CGSizeMake(CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT)];
    UIButton *artworkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [artworkButton setImage:buttonImage
                   forState:UIControlStateNormal];
    artworkButton.frame = CGRectMake(0, 0, CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT);
    UIBarButtonItem *artworkItem = [[UIBarButtonItem alloc] initWithCustomView:artworkButton];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.titleLabel.numberOfLines = 0;

    CGFloat defaultFontSize = titleButton.titleLabel.font.pointSize;
    CGFloat fontSize = defaultFontSize - 2;
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]};
    NSAttributedString *artistString = [[NSAttributedString alloc] initWithString:[nowPlayingItem.albumArtist stringByAppendingString:@"\n"]
                                                                       attributes:attribute];
    attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    NSAttributedString *itemTitleString = [[NSAttributedString alloc] initWithString:nowPlayingItem.title
                                                                          attributes:attribute];

    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:@""];
    [titleText appendAttributedString:artistString];
    [titleText appendAttributedString:itemTitleString];
    [titleButton setAttributedTitle:titleText
                           forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor blackColor]
                      forState:UIControlStateNormal];
    [titleButton sizeToFit];
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIBarButtonItem *titleBtn = [[UIBarButtonItem alloc] initWithCustomView:titleButton];
    
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                             target:nil
                                                                             action:nil];

    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil];
    
    [self setToolbarItems:@[artworkItem, flex, titleBtn, flex, playBtn]];
    
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
    return CELL_HEIGHT;
}

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
    
    if ([[GGBLibraryController nowPlayingItem].albumArtist isEqualToString:albumArtist]) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    }
    
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"indexPath %@", indexPath);
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
