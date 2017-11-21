//
//  GGBLibraryController.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface GGBLibraryController : NSObject

+ (void)start;
+ (void)stop;

+ (void)refreshCollections;

+ (void)playCollection:(MPMediaItemCollection *)collection;
+ (void)play;
+ (void)pause;
+ (void)next;
+ (void)beginning;
+ (void)previous;

+ (NSArray <NSString *> *)albumArtists;
+ (NSNumber *)numberOfAlbumsForAlbumArtist:(NSString *)albumArtist;
+ (NSNumber *)numberOfTracksForAlbumArtist:(NSString *)albumArtist;

+ (NSArray *)collectionsFilteredByAlbumArtist:(NSString *)albumArtist;
+ (NSArray *)albumsInfoForAlbumArtist:(NSString *)albumArtist;

+ (NSNumber *)numberOfTracksForAlbumTitle:(NSString *)albumTitle
                              albumArtist:(NSString *)albumArtist
                                     year:(NSNumber *)year
                               discNumber:(NSUInteger)discNumber;

+ (MPMediaItemCollection *)collectionForAlbumTitle:(NSString *)albumTitle
                                       albumArtist:(NSString *)albumArtist
                                              year:(NSNumber *)year
                                        discNumber:(NSUInteger)discNumber;

+ (MPMediaItem *)nowPlayingItem;
+ (MPMusicPlaybackState)playbackState;
+ (NSTimeInterval)currentPosition;
+ (void)setCurrentPosition:(NSTimeInterval)newPosition;


@end
