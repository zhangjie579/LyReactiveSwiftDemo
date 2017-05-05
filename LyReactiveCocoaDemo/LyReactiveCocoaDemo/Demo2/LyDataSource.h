//
//  LyDataSource.h
//  LyReactiveCocoaDemo
//
//  Created by 张杰 on 2017/5/4.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface LyDataSource : NSObject

@property(nonatomic,strong,readonly)RACCommand *commandLoadNewData;//用户加载网络请求

//用于绑定view
//个人感觉，这个类还是处理数据就好，不然实现绑定view，实现tableview的delegate,DataSource的话，其实就相当于代替了以前的vc
- (void)bindView:(UIView *)bindView;

@end
