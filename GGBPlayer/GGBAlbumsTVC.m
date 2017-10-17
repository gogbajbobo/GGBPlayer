//
//  GGBAlbumsTVC.m
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 17/10/2017.
//  Copyright © 2017 Maxim Grigoriev. All rights reserved.
//

#import "GGBAlbumsTVC.h"
#import "GGBLibraryController.h"


@interface GGBAlbumsTVC ()

@end


@implementation GGBAlbumsTVC

- (void)customInit {
    self.title = self.albumArtist;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GGBLibraryController numberOfAlbumsForAlbumArtist:self.albumArtist].integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
    return cell;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
