//
//  GGBAlbumArtistsTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBArtistsTVC.h"
#import "GGBAlbumsTVC.h"
#import "GGBHelper.h"


@interface GGBArtistsTVC ()

@property (nonatomic, strong) NSMutableArray *requestedArtistPictures;
@property (nonatomic, strong) NSMutableArray *noPictureArtist;


@end


@implementation GGBArtistsTVC

#pragma mark - variables setters and getters

- (NSMutableArray *)requestedArtistPictures {
    
    if (!_requestedArtistPictures) {
        _requestedArtistPictures = @[].mutableCopy;
    }
    return _requestedArtistPictures;
    
}

- (NSMutableArray *)noPictureArtist {
    
    if (!_noPictureArtist) {
        _noPictureArtist = @[].mutableCopy;
    }
    return _noPictureArtist;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    [super customInit];
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
        [super selectCell:cell];
    } else {
        [super unselectCell:cell];
    }
    
    NSNumber *numberOfAlbums = [GGBLibraryController numberOfAlbumsForAlbumArtist:albumArtist];
    NSNumber *numberOfTracks = [GGBLibraryController numberOfTracksForAlbumArtist:albumArtist];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"albums: %@, tracks: %@", numberOfAlbums, numberOfTracks];
    
    if (numberOfTracks.integerValue) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *imagePath = [GGBHelper thumbPicturePathForArtistName:albumArtist];
    
    UIImage *image;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        
        image = [UIImage imageWithContentsOfFile:imagePath];
        
    } else {
        
        image = [UIImage imageNamed:@"icons8-sad_male"];
        [self getArtistPictureForIndexPath:indexPath];
        
    }

    [self setImage:image
           forCell:cell];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showAlbum"
                              sender:indexPath];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"indexPath %@", indexPath);
}

- (void)getArtistPictureForIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.requestedArtistPictures containsObject:indexPath]) return;
    
    [self.requestedArtistPictures addObject:indexPath];

    NSString *albumArtist = [GGBLibraryController albumArtists][indexPath.row];
    
    if ([self.noPictureArtist containsObject:albumArtist]) return;

    [GGBHelper getArtistPicture:albumArtist completionHandler:^(BOOL success, NSData *imageData) {
        
        if (!success) {
            
            [self.requestedArtistPictures removeObject:indexPath];
            [self.noPictureArtist addObject:albumArtist];
            return;
            
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSString *dataPath = [GGBHelper thumbPicturePathForArtistName:albumArtist];
            
            [imageData writeToFile:dataPath
                        atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.requestedArtistPictures removeObject:indexPath];
                
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
                
            });
            
        });

    }];
    
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


#pragma mark - Notifications

- (NSPredicate *)nowPlayingPredicate {

    NSString *nowPlayingArtist = [GGBLibraryController nowPlayingItem].albumArtist;
    NSPredicate *nowPlayingPredicate = [NSPredicate predicateWithFormat:@"textLabel.text == %@", nowPlayingArtist];
    
    return nowPlayingPredicate;

}


#pragma mark - buttons

- (IBAction)refreshButtonPressed:(id)sender {
    
    [GGBLibraryController refreshCollections];
    [self.tableView reloadData];
    
}

@end
