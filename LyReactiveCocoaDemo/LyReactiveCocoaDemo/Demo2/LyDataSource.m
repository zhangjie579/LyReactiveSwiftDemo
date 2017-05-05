//
//  LyDataSource.m
//  LyReactiveCocoaDemo
//
//  Created by 张杰 on 2017/5/4.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyDataSource.h"

@interface LyDataSource ()

@property(nonatomic,strong)RACCommand *commandLoadNewData;

@end

@implementation LyDataSource

//用于绑定view
- (void)bindView:(UIView *)bindView
{
    
}

- (RACCommand *)commandLoadNewData
{
    if (!_commandLoadNewData) {
        @weakify(self)
        _commandLoadNewData = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                //请求网络
                [self loadData:subscriber];
                
                return nil;
            }];
            
        }];
    }
    return _commandLoadNewData;
}

//网络请求,json -> dict -> model -> viewModel
- (void)loadData:(id<RACSubscriber>)subscriber
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [subscriber sendNext:@"加载数据"];
    });
}

@end
