//
//  GGBAlbumsTVC.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GGBBaseTVC.h"


@interface GGBAlbumsTVC : GGBBaseTVC

@property (nonatomic, strong) NSString *albumArtist;
@property (nonatomic, strong) NSArray *albumsInfo;


@end
