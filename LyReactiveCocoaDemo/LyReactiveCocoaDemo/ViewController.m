//
//  ViewController.m
//  LyReactiveCocoaDemo
//
//  Created by 张杰 on 2017/2/14.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ViewController.h"
#import "LyViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()

@property(nonatomic,strong)RACCommand *conmmand;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/*
RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。

RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
使用场景:不想监听某个信号时，可以通过它主动取消订阅信号。
 
RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
使用场景:通常用来代替代理，有了它，就不必要定义代理了。
 
RACReplaySubject:重复提供信号类，RACSubject的子类。

RACReplaySubject与RACSubject区别:
RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。
使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
 */
- (void)test1
{
    //1.创建信号
    RACSignal *signgam = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //2.发送
        [subscriber sendNext:@1];
        
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    // 3.订阅信号,才会激活信号.
    [signgam subscribeNext:^(id  _Nullable x) {
        
    }];
}

//RACSubject
//RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
//使用场景:通常用来代替代理，有了它，就不必要定义代理了。
- (void)test2
{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];
}

//RACSubject替换代理delegate
- (IBAction)btnClick:(id)sender {
    
    // 创建第二个控制器
    LyViewController *twoVc = [[LyViewController alloc] init];
    
    // 设置代理信号
    twoVc.delegateSignal = [RACSubject subject];
    
    // 订阅代理信号
    [twoVc.delegateSignal subscribeNext:^(id x) {
        
        NSLog(@"收到第二个控制器返回来的消息");
    }];
    
    // 跳转到第二个控制器
    [self presentViewController:twoVc animated:YES completion:nil];
    
}

//RACReplaySubject
//使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。
//使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
- (void)test3
{
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
}

/*
RACTuple:元组类,类似NSArray,用来包装值.
RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
使用场景：1.字典转模型
 */
//RACSequence和RACTuple简单使用
- (void)test4
{
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    
    // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        
        // 相当于以下写法
        //        NSString *key = x[0];
        //        NSString *value = x[1];
        
        NSLog(@"%@ %@",key,value);
        
    }];
    
    
    // 3.字典转模型
    // 3.1 OC写法
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
//    
//    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
//    
//    NSMutableArray *items = [NSMutableArray array];
//    
//    for (NSDictionary *dict in dictArr) {
//        FlagItem *item = [FlagItem flagWithDict:dict];
//        [items addObject:item];
//    }
//    
//    // 3.2 RAC写法
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
//    
//    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
//    
//    NSMutableArray *flags = [NSMutableArray array];
//    
//    _flags = flags;
//    
//    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
//    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
//        // 运用RAC遍历字典，x：字典
//        
//        FlagItem *item = [FlagItem flagWithDict:x];
//        
//        [flags addObject:item];
//        
//    }];
//    
//    // 3.3 RAC高级写法:
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
//    
//    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
//    // map:映射的意思，目的：把原始值value映射成一个新值
//    // array: 把集合转换成数组
//    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
//    NSArray *flags = [[dictArr.rac_sequence map:^id(id value) {
//        
//        return [FlagItem flagWithDict:value];
//        
//    }] array];
}

/*
 RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
 
 使用注意:RACMulticastConnection通过RACSignal的-publish或者-muticast:方法创建
 */
- (void)test5
{
    // RACMulticastConnection使用步骤:
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.创建连接 RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
    // 4.连接 [connect connect]
    
    // RACMulticastConnection底层原理:
    // 1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
    // 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
    // 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
    // 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
    // 3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
    // 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
    // 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
    
    
    // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
    // 解决：使用RACMulticastConnection就能解决.
    
    // 1.创建请求信号
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        NSLog(@"发送请求");
        
        return nil;
    }];
    // 2.订阅信号
    [signal1 subscribeNext:^(id x) {
        
        NSLog(@"接收数据");
        
    }];
    // 2.订阅信号
    [signal1 subscribeNext:^(id x) {
        
        NSLog(@"接收数据");
        
    }];
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    
    
    // RACMulticastConnection:解决重复请求问题
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        NSLog(@"发送请求");
        [subscriber sendNext:@1];
        
        return nil;
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

/*
 RACCommand:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。
 
 使用场景:监听按钮点击，网络请求
 */
- (void)test6
{
    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
    // 1.signalBlock必须要返回一个信号，不能传nil.
    // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
    // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求
    
    
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        
        NSLog(@"执行命令");
        
        // 创建空信号,必须返回信号
        //        return [RACSignal empty];
        
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:@"请求数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            
            return nil;
        }];
        
    }];
    
    // 强引用命令，不要被销毁，否则接收不到数据
    _conmmand = command;
    
    
    // 3.执行命令
    [self.conmmand execute:@1];
    
    // 4.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
        
        [x subscribeNext:^(id x) {
            
            NSLog(@"%@",x);
        }];
        
    }];
    
    // RAC高级用法
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 5.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
            
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
        
    }];
}

- (void)test7
{
//    // 1.代替代理
//    // 需求：自定义redView,监听红色view中按钮点击
//    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
//    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
//    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
//    [[redV rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
//        NSLog(@"点击红色按钮");
//    }];
//    
//    // 2.KVO
//    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
//    // observer:可以传入nil
//    [[redV rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
//        
//        NSLog(@"%@",x);
//        
//    }];
//    
//    // 3.监听事件
//    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
//    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        
//        NSLog(@"按钮被点击了");
//    }];
//    
//    // 4.代替通知
//    // 把监听到的通知转换信号
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
//        NSLog(@"键盘弹出");
//    }];
//    
//    // 5.监听文本框的文字改变
//    [_textField.rac_textSignal subscribeNext:^(id x) {
//        
//        NSLog(@"文字改变了%@",x);
//    }];
    
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
}

// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
}

@end
