//
//  DemoTwoViewController.m
//  LyReactiveCocoaDemo
//
//  Created by 张杰 on 2017/5/4.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "DemoTwoViewController.h"
#import "LyDataSource.h"

@interface DemoTwoViewController ()

@property(nonatomic,strong)LyDataSource *dataSource;

@end

@implementation DemoTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
}

- (void)initData
{
    [[self.dataSource.commandLoadNewData execute:nil] subscribeNext:^(id  _Nullable x) {
        NSLog(@"----%@",x);
        //得到数据后，刷新UI
    }];
}

- (LyDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[LyDataSource alloc] init];
    }
    return _dataSource;
}

@end
