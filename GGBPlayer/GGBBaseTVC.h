//
//  GGBBaseTVC.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 05/11/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GGBConstants.h"
#import "GGBLibraryController.h"


@interface GGBBaseTVC : UITableViewController

@property (nonatomic, strong) UITableViewCell *selectedCell;


- (void)customInit;

- (NSPredicate *)nowPlayingPredicate;

- (void)setImage:(UIImage *)cellImage forCell:(UITableViewCell *)cell;
- (void)selectCell:(UITableViewCell *)cell;
- (void)unselectCell:(UITableViewCell *)cell;


@end
