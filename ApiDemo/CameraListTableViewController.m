//
//  CameraListTableViewController.m
//  ApiDemo
//
//  Created by chencancan on 2018/4/19.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import "CameraListTableViewController.h"
#import "C_GA_Open8200SDK.h"
#import "CameraInfo.h"
#import "NSObject+DXKeyValue.h"
#import "PlayerViewController.h"

@interface CameraListTableViewController ()

@property (nonatomic, strong) NSMutableArray *cameraList;

@end

@implementation CameraListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GAOpen8200ApiClient getCameraListStart:0 size:100 orderby:@"" order:@"" complete:^(NSArray *cameraArray, NSError *error) {
        NSArray *cameraInfoList = [CameraInfo DX_objectArrayWithKeyValuesArray:cameraArray];
        self.cameraList = [NSMutableArray arrayWithArray:cameraInfoList];
        [self.tableView reloadData];
    }];
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

    return self.cameraList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CameraInfo *cameraInfo = [self.cameraList objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = cameraInfo.name;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    CameraInfo *cameraInfo = [self.cameraList objectAtIndex:indexPath.row];
    PlayerViewController *vc = [[PlayerViewController alloc] init];
    vc.cameraInfo = cameraInfo;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
