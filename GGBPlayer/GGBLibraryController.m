//
//  GGBLibraryController.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBLibraryController.h"

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
    
    MPMediaQuery *mq = [MPMediaQuery albumsQuery];
    
    NSArray *albumArtists = [mq.collections valueForKeyPath:@"@distinctUnionOfObjects.representativeItem.albumArtist"];
    
    NSLog(@"%@", albumArtists);
    lc.collections = mq.collections;
    lc.albumArtists = albumArtists;
    
    for (MPMediaItemCollection *collection in mq.collections) {
        
        NSLog(@"%@", collection.representativeItem.albumArtist);
        NSLog(@"%@", collection.representativeItem.albumTitle);
        
        NSNumber *yearNumber = [collection.representativeItem valueForProperty:@"year"];
        
        if (yearNumber && [yearNumber isKindOfClass:[NSNumber class]]) {
            
            int year = yearNumber.intValue;
            if (year) {
                NSLog(@"%@", yearNumber);
            }
            
        }
        
//        NSLog(@"%@", [collection.items valueForKeyPath:@"title"]);
        
    }
    
}

+ (void)playCollection:(MPMediaItemCollection *)collection {
    
    MPMusicPlayerController *pc = [self sharedLibraryController].playerController;
    
    [pc setQueueWithItemCollection:collection];
    [pc setNowPlayingItem:collection.items.firstObject];
    [pc prepareToPlay];
    [pc play];
    
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


@end
