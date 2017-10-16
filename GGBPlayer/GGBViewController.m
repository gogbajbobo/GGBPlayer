//
//  ViewController.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 16/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBViewController.h"

#import "GGBLibraryController.h"


@interface GGBViewController ()

@end

@implementation GGBViewController

- (void)customInit {
    
    [GGBLibraryController start];
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self customInit];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
