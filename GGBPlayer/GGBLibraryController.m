//
//  GGBLibraryController.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBLibraryController.h"

#import "GGBPrivateConstants.h"


@interface GGBLibraryController()

@property (nonatomic, strong) MPMusicPlayerController *playerController;
@property (nonatomic, strong) NSArray *collections;
@property (nonatomic, strong) NSArray *albumArtists;


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

+ (NSArray *)albumArtists {
    
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

+ (NSNumber *)numberOfTracksForAlbumTitle:(NSString *)albumTitle andAlbumArtist:(NSString *)albumArtist {
    
    MPMediaItemCollection *collection = [self collectionForAlbumTitle:albumTitle
                                                       andAlbumArtist:albumArtist];
    
    return @(collection.count);
    
}

+ (MPMediaItemCollection *)collectionForAlbumTitle:(NSString *)albumTitle andAlbumArtist:(NSString *)albumArtist {

    NSArray *filteredCollections = [self collectionsFilteredByAlbumArtist:albumArtist];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"representativeItem.albumTitle == %@", albumTitle];
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

+ (void)getArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {
    
    NSString *urlString = @"https://api.discogs.com/database/search?q=";
    urlString = [urlString stringByAppendingString:artistName];
    urlString = [urlString stringByAppendingString:@"&type=artist&token="];
    urlString = [urlString stringByAppendingString:DISCOGS_TOKEN];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        id dataObject = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        if (!dataObject || ![dataObject isKindOfClass:[NSDictionary class]]) {
            
            completionHandler(NO, nil);
            return;
            
        }
        
        NSDictionary *jsonObject = (NSDictionary *)dataObject;
        NSArray *results = jsonObject[@"results"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title like[cd] %@", artistName];
        results = [results filteredArrayUsingPredicate:predicate];
        
        NSDictionary *result = results.firstObject;
        NSString *thumbUrlString = result[@"thumb"];
        
        if (!thumbUrlString) {

            completionHandler(NO, nil);
            return;

        }
        
        NSURL *thumbUrl = [NSURL URLWithString:thumbUrlString];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:thumbUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!data) {
                
                completionHandler(NO, nil);
                return;

            }
            
            completionHandler(YES, data);
            
        }] resume];
        
    }] resume];
    
}


@end
