//
//  GGBLibraryController.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBLibraryController.h"

#import "GGBHelper.h"
#import "GGBConstants.h"


@interface GGBLibraryController()

@property (nonatomic, strong) MPMusicPlayerController *playerController;
@property (nonatomic, strong) NSArray *collections;
@property (nonatomic, strong) NSArray <NSString *> *albumArtists;


@end


@implementation GGBLibraryController

+ (GGBLibraryController *)sharedLibraryController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (void)start {
    
    GGBLibraryController *lc = [self sharedLibraryController];
    
    lc.playerController = [MPMusicPlayerController systemMusicPlayer];
    [lc.playerController beginGeneratingPlaybackNotifications];

    [self refreshCollections];
    
}

+ (void)stop {
    [[self sharedLibraryController].playerController endGeneratingPlaybackNotifications];
}

+ (void)refreshCollections {

    GGBLibraryController *lc = [self sharedLibraryController];
    
    MPMediaQuery *mq = [MPMediaQuery albumsQuery];
    
    NSMutableArray *filteredCollections = @[].mutableCopy;
    
    for (MPMediaItemCollection *collection in mq.collections) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetURL != nil"];
        NSArray *filteredItems = [collection.items filteredArrayUsingPredicate:predicate];
        
        if (!filteredItems.count) continue;
        
        [filteredCollections addObject:[MPMediaItemCollection collectionWithItems:filteredItems]];

    }
    
    NSArray *albumArtists = [filteredCollections valueForKeyPath:@"@distinctUnionOfObjects.representativeItem.albumArtist"];
    lc.collections = filteredCollections;
    lc.albumArtists = albumArtists;

    [GGBHelper checkArtistPictures];
    
}

+ (void)playCollection:(MPMediaItemCollection *)collection {
    
    MPMusicPlayerController *pc = [self sharedLibraryController].playerController;
    
    [pc setQueueWithItemCollection:collection];
    [pc setNowPlayingItem:collection.items.firstObject];

    [self play];
    
}

+ (void)play {

    MPMusicPlayerController *pc = [self sharedLibraryController].playerController;
    
    [pc prepareToPlay];
    [pc play];

}

+ (void)pause {
    [[self sharedLibraryController].playerController pause];
}

+ (void)next {
    [[self sharedLibraryController].playerController skipToNextItem];
}

+ (void)beginning {
    [[self sharedLibraryController].playerController skipToBeginning];
}

+ (void)previous {
    [[self sharedLibraryController].playerController skipToPreviousItem];
}

+ (NSArray <NSString *> *)albumArtists {
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                 ascending:YES
                                                                  selector:@selector(caseInsensitiveCompare:)];
    
    return [[self sharedLibraryController].albumArtists sortedArrayUsingDescriptors:@[sortByName]];
    
}

+ (NSArray *)collectionsFilteredByAlbumArtist:(NSString *)albumArtist {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"representativeItem.albumArtist == %@", albumArtist];
    NSArray *filteredCollections = [[self sharedLibraryController].collections filteredArrayUsingPredicate:predicate];

    return filteredCollections;
    
}

+ (NSNumber *)numberOfAlbumsForAlbumArtist:(NSString *)albumArtist {
    
    NSArray *filteredCollections = [self collectionsFilteredByAlbumArtist:albumArtist];
    return @(filteredCollections.count);
    
}

+ (NSNumber *)numberOfTracksForAlbumArtist:(NSString *)albumArtist {

    NSArray *filteredCollections = [self collectionsFilteredByAlbumArtist:albumArtist];
    return [filteredCollections valueForKeyPath:@"@sum.self.count"];
    
}

+ (NSArray *)albumsInfoForAlbumArtist:(NSString *)albumArtist {
    
    NSArray *filteredCollections = [self collectionsFilteredByAlbumArtist:albumArtist];
    return [filteredCollections valueForKeyPath:@"representativeItem"];
    
}

+ (NSNumber *)numberOfTracksForAlbumTitle:(NSString *)albumTitle albumArtist:(NSString *)albumArtist year:(NSNumber *)year discNumber:(NSUInteger)discNumber {
    
    MPMediaItemCollection *collection = [self collectionForAlbumTitle:albumTitle
                                                       albumArtist:albumArtist
                                                                 year:year
                                                           discNumber:discNumber];
    
    return @(collection.count);
    
}

+ (MPMediaItemCollection *)collectionForAlbumTitle:(NSString *)albumTitle albumArtist:(NSString *)albumArtist year:(NSNumber *)year discNumber:(NSUInteger)discNumber {

    NSArray *filteredCollections = [self collectionsFilteredByAlbumArtist:albumArtist];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"representativeItem.albumTitle == %@", albumTitle];
    filteredCollections = [filteredCollections filteredArrayUsingPredicate:predicate];

    predicate = [NSPredicate predicateWithFormat:@"representativeItem.year == %@", year];
    filteredCollections = [filteredCollections filteredArrayUsingPredicate:predicate];

    predicate = [NSPredicate predicateWithFormat:@"representativeItem.discNumber == %@", @(discNumber)];
    filteredCollections = [filteredCollections filteredArrayUsingPredicate:predicate];

    MPMediaItemCollection *collection = filteredCollections.firstObject;

    return collection;
    
}

+ (MPMediaItem *)nowPlayingItem{
    return [self sharedLibraryController].playerController.nowPlayingItem;
}

+ (MPMusicPlaybackState)playbackState {
    return [self sharedLibraryController].playerController.playbackState;
}

+ (NSTimeInterval)currentPosition {
    return [self sharedLibraryController].playerController.currentPlaybackTime;
}

+ (void)setCurrentPosition:(NSTimeInterval)newPosition {
    [self sharedLibraryController].playerController.currentPlaybackTime = newPosition;
}

+ (void)likeItem:(MPMediaItem *)item {
    
    NSUInteger newRating = (item.rating == 5) ? 0 : 5;
    
    [item setValue:@(newRating)
            forKey:MPMediaItemPropertyRating];

    [[NSNotificationCenter defaultCenter] postNotificationName:GGBMediaItemDidChange
                                                        object:item];
    
}


@end
