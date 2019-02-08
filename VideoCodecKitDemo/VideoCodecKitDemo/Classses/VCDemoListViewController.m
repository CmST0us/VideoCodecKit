//
//  VCDemoListViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoListViewController.h"
#import "VCDemoISOTestViewController.h"
#import "VCDemoEncoderTestViewController.h"
#import "VCDemoMicRecorderTestViewController.h"
#import "VCDemoFLVAudioPlayTestViewController.h"

@interface VCDemoListViewController ()

@end

@implementation VCDemoListViewController

- (NSArray *)testCases {
    static NSArray *cases = nil;
    if (cases != nil) return cases;
    cases = @[
              @{
                  @"title":@"FLV播放",
                  @"class":NSStringFromClass([VCDemoISOTestViewController class]),
                },
              @{
                  @"title":@"录制为FLV",
                  @"class":NSStringFromClass([VCDemoEncoderTestViewController class]),
                  },
              @{
                  @"title":@"麦克风录音",
                  @"class":NSStringFromClass([VCDemoMicRecorderTestViewController class]),
                  },
              @{
                  @"title":@"FLV音频播放，立体声测试",
                  @"class":NSStringFromClass([VCDemoFLVAudioPlayTestViewController class]),
                  },
              ];
    return cases;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self testCases].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dict = [[self testCases] objectAtIndex:indexPath.row];
    cell.textLabel.text = dict[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [[self testCases] objectAtIndex:indexPath.row];
    Class targetClass = NSClassFromString(dict[@"class"]);
    UIViewController *vc = [(UIViewController *)[targetClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
