//
//  GGBBaseTracksTVC.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 06/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBBaseTVC.h"

@interface GGBBaseTracksTVC : GGBBaseTVC

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                 withMediaItem:(MPMediaItem *)item;


@end
