//
//  GGBLibraryController.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBLibraryController.h"

@interface GGBLibraryController()

@property (nonatomic, strong) NSArray *collections;
@property (nonatomic, strong) NSArray *albumArtists;


@end


@implementation GGBLibraryController

+ (instancetype)sharedLibraryController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (void)start {
    
//    MPMusicPlayerController *pc = [MPMusicPlayerController systemMusicPlayer];
    MPMediaQuery *mq = [MPMediaQuery albumsQuery];
    
    NSArray *albumArtists = [mq.collections valueForKeyPath:@"@distinctUnionOfObjects.representativeItem.albumArtist"];
    
    NSLog(@"%@", albumArtists);
    [GGBLibraryController sharedLibraryController].collections = mq.collections;
    [GGBLibraryController sharedLibraryController].albumArtists = albumArtists;    
    
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

+ (NSArray *)albumArtists {
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                 ascending:YES
                                                                  selector:@selector(caseInsensitiveCompare:)];
    
    return [[GGBLibraryController sharedLibraryController].albumArtists sortedArrayUsingDescriptors:@[sortByName]];
    
}

+ (NSArray *)collectionsFilteredByAlbumArtist:(NSString *)albumArtist {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"representativeItem.albumArtist == %@", albumArtist];
    NSArray *filteredCollections = [[GGBLibraryController sharedLibraryController].collections filteredArrayUsingPredicate:predicate];

    return filteredCollections;
    
}

+ (NSNumber *)numberOfAlbumsForAlbumArtist:(NSString *)albumArtist {
    
    NSArray *filteredCollections = [GGBLibraryController collectionsFilteredByAlbumArtist:albumArtist];
    return @(filteredCollections.count);
    
}

+ (NSNumber *)numberOfTracksForAlbumArtist:(NSString *)albumArtist {

    NSArray *filteredCollections = [GGBLibraryController collectionsFilteredByAlbumArtist:albumArtist];
    return [filteredCollections valueForKeyPath:@"@sum.self.count"];
    
}


@end
