//
//  LyDemoViewController.m
//  LySwiftDemo
//
//  Created by 张杰 on 2017/3/1.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyDemoViewController.h"
#import "LyHeardView.h"
#import "LyModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface LyDemoViewController ()

@property(nonatomic,strong)LyHeardView *heardView;
@property(nonatomic,strong)UITextField *textField_num;
@property(nonatomic,strong)UITextField *textField_cell;
@property(nonatomic,strong)UIButton    *btn;
@property(nonatomic,strong)UILabel     *label;

@end

@implementation LyDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self initData];
    
//    [self test];
    [self test5];
    
}

//过滤
- (void)test1
{
    //1.filter:过滤信号，使用它可以获取满足条件的信号
    [self.textField_num.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        
        return value.length > 3;
    }];
    
    //2.ignore:忽略完某些值的信号
    [[self.textField_num.rac_textSignal ignore:@"1"] subscribeNext:^(NSString * _Nullable x) {
        
    }];
    
    //3.distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉
    //使用场合:在开发中，刷新UI经常使用，只有两次数据不一样才需要刷新
    [[self.textField_num.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString * _Nullable x) {
        
    }];
}

- (void)test2
{
    //take:从开始一共取N次的信号
    // 1、创建信号
    RACSubject *signal = [RACSubject subject];
    
    // 2、处理信号，订阅信号
    [[signal take:1] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [signal sendNext:@1];
    
    [signal sendNext:@2];
}

//takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
- (void)test3
{
    // 1、创建信号
    RACSubject *signal = [RACSubject subject];
    
    // 2、处理信号，订阅信号
    [[signal takeLast:1] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [signal sendNext:@1];
    
    [signal sendNext:@2];
    
    //一定不能少
    [signal sendCompleted];
}

- (void)test4
{
    //1.takeUntil:(RACSignal *):获取信号直到执行完这个信号
    // 监听文本框的改变，知道当前对象被销毁
    [self.textField_num.rac_textSignal takeUntil:self.rac_willDeallocSignal];
    
    //2.skip:(NSUInteger):跳过几个信号,不接受
    // 表示输入第一次，不会被监听到，跳过第一次发出的信号
    [[self.textField_num.rac_textSignal skip:1] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    //3.switchToLatest
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    [signalOfSignals sendNext:signal];
    [signal sendNext:@1];
    
    // 获取信号中信号最近发出信号，订阅最近发出的信号。
    // 注意switchToLatest：只能用于信号中的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    [[signalOfSignals skip:1] subscribeNext:^(id  _Nullable x) {
        
    }];
}

//秩序。
- (void)test5
{
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        // 执行[subscriber sendNext:@1];之前会调用这个Block
        NSLog(@"doNext");;
    }] doCompleted:^{
        // 执行[subscriber sendCompleted];之前会调用这个Block
        NSLog(@"doCompleted");;
        
    }] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

//时间
- (void)test6
{
    //1.timeout：超时，可以让一个信号在一定的时间后，自动报错
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        // 1秒后会自动调用
        NSLog(@"%@",error);
    }];
    
    //2.interval 定时：每隔一段时间发出信号
    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    //3.delay 延迟发送next。
    RACSignal *signal1 = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        return nil;
    }] delay:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

#pragma mark - 高级方法
//绑定(bind),映射(flattenMap,Map)
- (void)testWithBind
{
    //1.bind
    [[self.textField_num.rac_textSignal bind:^RACSignalBindBlock _Nonnull{
        
        return ^RACSignal *(id value, BOOL *stop){
            
            return [RACSignal return:[NSString stringWithFormat:@"输出:%@",value]];
        };
        
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //2.flattenMap
    [[self.textField_num.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        
        return [RACSignal return:[NSString stringWithFormat:@"输出:%@",value]];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //3.map
    [[self.textField_num.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        
        return [NSString stringWithFormat:@"输出:%@",value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

//组合(concat),必须前面的信号发送完成了，后面信号才能收到
- (void)concat
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
#warning 注意:如果不调用sendCompleted，B信号就收不到
        [subscriber sendCompleted];
        
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活。
    RACSignal *concatSignal = [signalA concat:signalB];
    
    // 以后只需要面对拼接信号开发。
    // 订阅拼接的信号，不需要单独订阅signalA，signalB
    // 内部会自动订阅。
    // 注意：第一个信号必须发送完成，第二个信号才会被激活
    [concatSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    // concat底层实现:
    // 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
    // 2.didSubscribe中，会先订阅第一个源信号（signalA）
    // 3.会执行第一个源信号（signalA）的didSubscribe
    // 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
    // 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
    // 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
    // 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
}

// merge:把多个信号合并成一个信号
- (void)testWithCombine
{
    // merge:把多个信号合并成一个信号
    //创建多个信号
    // 底层实现：
    // 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
    // 2.每发出一个信号，这个信号就会被订阅
    // 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
    // 4.只要有一个信号被发出就会被监听。
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
}

// then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号
// 注意使用then，之前信号的值会被忽略掉.
- (void)testWithThen
{
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
#warning 注意:如果不调用sendCompleted，就收不到信号
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        
        // 只能接收到第二个信号的值，也就是then返回信号的值
        NSLog(@"%@",x);
    }];
}

//zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件
- (void)zip
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 压缩信号A，信号B
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        
        RACTupleUnpack(NSNumber *num, NSNumber *num2, NSNumber *num3) = x;
        NSLog(@"%@ %@ %@",num,num2,num3);
    }];
    
    // 底层实现:
    // 1.定义压缩信号，内部就会自动订阅signalA，signalB
    // 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出。
}

//combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号
- (void)combineLatestWith
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 把两个信号组合成一个信号,跟zip一样，没什么区别
    RACSignal *combineSignal = [signalA combineLatestWith:signalB];
    
    [combineSignal subscribeNext:^(RACTuple *x) {

        NSLog(@"%@ count = %ld",x,x.count);
    }];
    
    // 底层实现：
    // 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
    // 2.并且把两个信号组合成元组发出。
}

//聚合
- (void)reduce
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 聚合
    // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,signalB] reduce:^id _Nullable(NSNumber *num1 ,NSNumber *num2){
        
        return [NSString stringWithFormat:@"%@ %@",num1,num2];
        
    }];
    
    [reduceSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 底层实现:
    // 1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值
}

#pragma mark - 普通方法

//ReactiveCocoa常见宏
- (void)test
{
    //1.用于给某个对象的某个属性绑定
    RAC(self.label, text) = self.textField_num.rac_textSignal;
    
    //2.监听某个对象的某个属性,返回的是信号
    [RACObserve(self.label, text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"label   %@",x);
    }];
    
    //3.@weakify(Obj)和@strongify(Obj),一般两个都是配套使用,解决循环引用问题
    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self)
        
        NSLog(@"%@",self);
        
        return nil;
    }];
}

- (void)initView
{
    self.title = @"RAC例子";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.heardView];
    [self.view addSubview:self.textField_num];
    [self.view addSubview:self.textField_cell];
    [self.view addSubview:self.btn];
    [self.view addSubview:self.label];
    
    //1.KVO
    [[self.heardView rac_valuesAndChangesForKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
        
    }];
    
    //2.代替通知
    // 把监听到的通知转换信号
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
    //3.监听文本框的文字改变
    RACSignal *signal1 = [self.textField_num rac_textSignal];
    RACSignal *signal2 = [self.textField_cell rac_textSignal];
    
    //4.多个信号连用
//    [self rac_liftSelector:@selector(changeBtnStatusWithSig1:sig2:) withSignals:signal1,signal2, nil];
    
    //多个信号连用
    [[RACSignal combineLatest:@[signal1,signal2]] subscribeNext:^(id  _Nullable x) {
        
        RACTupleUnpack(NSString *str1 , NSString *str2) = x;
        
        self.btn.enabled = (str1.length > 0 && str2.length > 0);
    }];
}

- (void)changeBtnStatusWithSig1:(NSString *)str1 sig2:(NSString *)str2
{
//    NSLog(@"1   %@,2   %@",data1,data2);
    
    self.btn.enabled = (str1.length > 0 && str2.length > 0);
    
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    
//    self.heardView.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width, 300);
//}

//RAC代替delegate的方式
- (void)delegateWithRAC
{
    //订阅信号
    //第一种方式：回调
    [self.heardView.subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"点击了%@",x);
    }];

    //第二种
    [[self.heardView rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack_(UIButton *btn) = x;
        NSLog(@"点击了%@",btn.currentTitle);
    }];
}

// RACMulticastConnection:解决重复请求问题
- (void)replyRAC
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@""];
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    
    // 2.创建连接
    RACMulticastConnection *connect = [signal publish];
    
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者一信号");
        
    }];
    
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者二信号");
        
    }];
    
    // 4.连接,激活信号
    [connect connect];
}

//命令RACCommand
- (void)executionSignals
{
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // input:执行命令传入参数
        // Block调用:执行命令的时候就会调用
        NSLog(@"%@",input);
        
#warning 注意：不能返回nil，如果不需要传递数据可以返回[RACSignal empty]
//        return [RACSignal empty];
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 发送数据
            [subscriber sendNext:@"执行命令产生的数据"];
            
            return nil;
        }];
    }];
    
    // 订阅信号
#warning 注意:必须要在执行命令前,订阅
    //executionSignals:信号源,信号中信号,signalOfSignals:信号:发送数据就是信号
    //第1种
    [command.executionSignals subscribeNext:^(RACSignal *x) {

        [x subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];

    }];
    
    // switchToLatest获取最新发送的信号,只能用于信号中信号
    //第2种
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    //第3种
    [[command.executionSignals skip:1] subscribeNext:^(id  _Nullable x) {
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
            
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
    }];
    
    // 2.执行命令
    [command execute:@1];
    
    [[self rac_valuesForKeyPath:@keypath(self,view.frame) observer:self] subscribeNext:^(id  _Nullable x) {
        
    }];
}

- (void)initData
{
    NSDictionary *dict1 = @{@"name" : @"mc" , @"title" : @"1"};
    NSDictionary *dict2 = @{@"name" : @"yj" , @"title" : @"2"};
    NSDictionary *dict3 = @{@"name" : @"lf" , @"title" : @"3"};
    NSArray *array = @[dict1,dict2,dict3];
    
    //字典遍历
    [dict1.rac_sequence.signal subscribeNext:^(RACTuple * _Nullable x) {
        
        RACTupleUnpack(NSString *key , NSString *value) = x;
        
    }];
    
    NSMutableArray *arrayModel = [[NSMutableArray alloc] init];
    
    //字典数组 -> model数组
    //第1种
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        
        LyModel *model = [LyModel modelWithDict:x];
        [arrayModel addObject:model];
        
    } completed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据
            //注意：由于处理数据是在子线程,so要在主线程刷新UI,而且是在completed这才完成数据处理
        });
    }];
    
    //第2种
    NSArray *modelArray = [[array.rac_sequence map:^id _Nullable(id  _Nullable value) {
        
        return [LyModel modelWithDict:value];
        
    }] array];
}

//避免重复订阅信号
- (void)test7
{
    /**
     RACDynamicSignal
     */
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"123"];
        return nil;
    }];
    
    RACMulticastConnection *connect = [signal publish];
    
    [connect.signal subscribeNext:^(id  _Nullable x) {
        
    }];
    
    [connect connect];
}


- (void)test8
{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        //注意:这里不能返回nil,可以返回空信号[RACSignal empty];
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendNext:@"1"];
            return nil;
        }];
        
    }];
    
    //第1种
    //执行execute就会执行
    [[command execute:@1] subscribeNext:^(id  _Nullable x) {
        
    }];
    
    //第2种
    //订阅信号
    //注意:订阅信号要在execute之前
    [command.executionSignals subscribeNext:^(id  _Nullable x) {
        [x subscribeNext:^(id  _Nullable x) {
            
        }];
    }];
    
    //第3种
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        
    }];
    
    
    //注意:一定要执行sendCompleted,否则不会执行完成
    [[command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        BOOL isEx = [x boolValue];
        if (isEx) {
            NSLog(@"正在执行");
        } else {
            NSLog(@"执行完成");
        }
    }];
    
    [command execute:@1];
}

- (void)test9
{
    UIButton *btn = [[UIButton alloc] init];
    
    //第1种
    btn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"1"];
            return nil;
        }];
        
    }];
    
    //第2种
    RACSubject *subject = [RACSubject subject];
    btn.rac_command = [[RACCommand alloc] initWithEnabled:subject signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"1"];
            return nil;
        }];
    }];
    
    [[btn.rac_command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        BOOL isEx = [x boolValue];
        [subject sendNext:@(!isEx)];
    }];
    
    //监听
    [btn.rac_command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        
    }];
}

- (LyHeardView *)heardView
{
    if (!_heardView) {
        _heardView = [[LyHeardView alloc] init];
        _heardView.backgroundColor = [UIColor redColor];
        _heardView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200);
    }
    return _heardView;
}

- (UITextField *)textField_cell
{
    if (!_textField_cell) {
        _textField_cell = [[UITextField alloc] init];
        _textField_cell.frame = CGRectMake(0, 300, 100, 30);
        _textField_cell.backgroundColor = [UIColor yellowColor];
    }
    return _textField_cell;
}

- (UITextField *)textField_num
{
    if (!_textField_num) {
        _textField_num = [[UITextField alloc] init];
        _textField_num.frame = CGRectMake(150, 300, 100, 30);
        _textField_num.backgroundColor = [UIColor orangeColor];
    }
    return _textField_num;
}

- (UIButton *)btn
{
    if (!_btn) {
        _btn = [[UIButton alloc] init];
        _btn.backgroundColor = [UIColor blueColor];
        [_btn setTitle:@"可以点击" forState:UIControlStateNormal];
        [_btn setTitle:@"不可点击" forState:UIControlStateDisabled];
        [_btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _btn.enabled = NO;
        _btn.frame = CGRectMake(0, 350, 200, 30);
    }
    return _btn;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor blackColor];
        _label.frame = CGRectMake(220, 350, 200, 30);
    }
    return _label;
}

@end
