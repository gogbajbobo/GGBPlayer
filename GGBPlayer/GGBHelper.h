//
//  GGBHelper.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGBHelper : NSObject

+ (void)getArtistPicture:(NSString *)artistName
       completionHandler:(void (^)(BOOL success, NSData *imageData))completionHandler;

+ (void)checkArtistPictures;

+ (NSString *)thumbPicturePathForArtistName:(NSString *)artistName;


@end
