//
//  GGBHelper.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBHelper.h"

#import "GGBPrivateConstants.h"
#import "GGBLibraryController.h"

#define PIC_FILE_EXTENTION @".picdat"


@implementation GGBHelper

+ (NSString *)firstDB {
    return DISCOGS_ARTIST_DB; // have to get this value from settings
}

+ (NSString *)secondDB {
    return LASTFM_ARTIST_DB; // have to get this value from settings
}

+ (void)getArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {
    
    if (!completionHandler) return;
    
    //TODO: have to select database (discogs or lastfm) by priority in settings
    
    if ([[self firstDB] isEqualToString:DISCOGS_ARTIST_DB]) {
    
        return [self getDiscogsArtistPicture:artistName
                           completionHandler:completionHandler];

    }

    if ([[self firstDB] isEqualToString:LASTFM_ARTIST_DB]) {
        
        return [self getLastfmArtistPicture:artistName
                          completionHandler:completionHandler];
        
    }
    
    completionHandler(NO, nil);
    
}

+ (void)getDiscogsArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {
    
    if (!completionHandler) return;
    
    NSString *urlString = @"https://api.discogs.com/database/search?q=";
    urlString = [urlString stringByAppendingString:artistName];
    urlString = [urlString stringByAppendingString:@"&type=artist&token="];
    urlString = [urlString stringByAppendingString:DISCOGS_TOKEN];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id dataObject = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        if (!dataObject || ![dataObject isKindOfClass:[NSDictionary class]]) {
            
            return [self discogsHaveNoArtistPicture:artistName
                                  completionHandler:completionHandler];
            
        }
        
        NSDictionary *jsonObject = (NSDictionary *)dataObject;
        NSArray *results = jsonObject[@"results"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title like[cd] %@", artistName];
        results = [results filteredArrayUsingPredicate:predicate];
        
        NSDictionary *result = results.firstObject;
        NSString *thumbUrlString = result[@"thumb"];
        
        if (!thumbUrlString) {

            return [self discogsHaveNoArtistPicture:artistName
                                  completionHandler:completionHandler];

        }
        
        thumbUrlString = [thumbUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSURL *thumbUrl = [NSURL URLWithString:thumbUrlString];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:thumbUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!data) {

                return [self discogsHaveNoArtistPicture:artistName
                                      completionHandler:completionHandler];

            }
            
            completionHandler(YES, data);
            
        }] resume];
        
    }] resume];
    
}

+ (void)discogsHaveNoArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {

    if (!completionHandler) return;
    
    NSLog(@"have no %@ image on discogs", artistName);
    
    if ([DISCOGS_ARTIST_DB isEqualToString:[self firstDB]] && [self secondDB]) {
        
        if ([[self secondDB] isEqualToString:LASTFM_ARTIST_DB]) {
            
            NSLog(@"go to lastfm");
            
            return [self getLastfmArtistPicture:artistName
                              completionHandler:completionHandler];
            
        }
        
    }
    
    completionHandler(NO, nil);
    return;

}

+ (void)getLastfmArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {
    
    if (!completionHandler) return;
    
    NSString *urlString = @"https://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=";
    urlString = [urlString stringByAppendingString:artistName];
    urlString = [urlString stringByAppendingString:@"&format=json&api_key="];
    urlString = [urlString stringByAppendingString:LASTFM_APIKEY];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id dataObject = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        if (!dataObject || ![dataObject isKindOfClass:[NSDictionary class]] || dataObject[@"error"]) {
            
            return [self lastfmHaveNoArtistPicture:artistName
                                 completionHandler:completionHandler];
            
        }
        
        NSDictionary *jsonObject = (NSDictionary *)dataObject;
        
        NSDictionary *artistInfo = jsonObject[@"artist"];
        
        NSArray <NSDictionary *> *artistImages = artistInfo[@"image"];
        
/* do not know why code below not working
         
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"size like[cd] %@", @"large"];
        NSArray *results = [artistImages filteredArrayUsingPredicate:predicate];
        
        NSDictionary *result = results.firstObject;
        NSString *thumbUrlString = result[@"#text"];
         
*/

        __block NSString *thumbUrlString = nil;

        [artistImages enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            if ([obj[@"size"] isEqualToString:@"large"]) {
                
                thumbUrlString = obj[@"#text"];
                *stop = YES;
                
            }
            
        }];

        if (!thumbUrlString) {
            
            return [self lastfmHaveNoArtistPicture:artistName
                                 completionHandler:completionHandler];
            
        }
        
        thumbUrlString = [thumbUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSURL *thumbUrl = [NSURL URLWithString:thumbUrlString];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:thumbUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!data) {
                
                return [self lastfmHaveNoArtistPicture:artistName
                                     completionHandler:completionHandler];
                
            }
            
            completionHandler(YES, data);
            
        }] resume];
        
    }] resume];
    
}

+ (void)lastfmHaveNoArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {
    
    if (!completionHandler) return;
    
    NSLog(@"have no %@ image on lastfm", artistName);

    if ([LASTFM_ARTIST_DB isEqualToString:[self firstDB]] && [self secondDB]) {
        
        if ([[self secondDB] isEqualToString:DISCOGS_ARTIST_DB]) {
            
            NSLog(@"go to discogs");
            
            return [self getDiscogsArtistPicture:artistName
                               completionHandler:completionHandler];
            
        }
        
    }

    completionHandler(NO, nil);
    return;
    
}

+ (void)checkArtistPictures {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray <NSString *> *albumArtists = [GGBLibraryController albumArtists];
    
    NSArray <NSString *> *cachesContent = [fileManager contentsOfDirectoryAtPath:[self cachesDirectory]
                                                                           error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith %@", PIC_FILE_EXTENTION];
    
    cachesContent = [cachesContent filteredArrayUsingPredicate:predicate];

    [cachesContent enumerateObjectsUsingBlock:^(NSString * _Nonnull objPath, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *fileName = objPath.lastPathComponent.stringByDeletingPathExtension;
        
        if (![albumArtists containsObject:fileName]) {
            
            [fileManager removeItemAtPath:objPath
                                    error:nil];
            
        }
        
    }];
    
}

+ (NSString *)thumbPicturePathForArtistName:(NSString *)artistName {
    
    NSString *fileName = [artistName stringByAppendingString:PIC_FILE_EXTENTION];
    NSString *dataPath = [[self cachesDirectory] stringByAppendingPathComponent:fileName];
    
    return dataPath;
    
}

+ (NSString *)cachesDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    return cachesDirectory;

}


@end
