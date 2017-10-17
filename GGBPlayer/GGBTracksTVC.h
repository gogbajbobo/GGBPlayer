//
//  GGBTracksTVC.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGBLibraryController.h"


@interface GGBTracksTVC : UITableViewController

@property (nonatomic, strong) MPMediaItem *albumInfo;
@property (nonatomic, strong) MPMediaItemCollection *collection;


@end
