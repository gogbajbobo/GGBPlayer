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

+ (void)getArtistPicture:(NSString *)artistName completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler {
    
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
        
        thumbUrlString = [thumbUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
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
