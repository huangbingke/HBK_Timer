//
//  ViewController.m
//  HBK_Timer
//
//  Created by 黄冰珂 on 2018/5/29.
//  Copyright © 2018年 KK. All rights reserved.
//

/*
 当使用NSTimer的scheduledTimerWithTimeInterval方法时。事实上此时Timer会被加入到当前线程的Run Loop中，且模式是默认的NSDefaultRunLoopMode。而如果当前线程就是主线程，也就是UI线程时，某些UI事件，比如UIScrollView的拖动操作，会将Run Loop切换成NSEventTrackingRunLoopMode模式，在这个过程中，默认的NSDefaultRunLoopMode模式中注册的事件是不会被执行的。也就是说，此时使用scheduledTimerWithTimeInterval添加到Run Loop中的Timer就不会执行。
 
 所以为了设置一个不被UI干扰的Timer，我们需要手动创建一个Timer，然后使用NSRunLoop的addTimer:forMode:方法来把Timer按照指定模式加入到Run Loop中。这里使用的模式是：NSRunLoopCommonModes，这个模式等效于NSDefaultRunLoopMode和NSEventTrackingRunLoopMode的结合。（参考Apple文档）
 
 经过我自己的实验，确实是这样，当我滑动UIScrollView的时候，NSTimer的处理时间根本没有调用，当我松手的时候，又执行了。
 */


#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) NSInteger count;


@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_queue_t queue = dispatch_queue_create("aaa", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self addTimer];
    });
//    dispatch_async(queue, ^{
//        [self GCDTimer];
//    });
    
    
    
    [self.view addSubview:self.myTableView];
//    [self addTimer];
}
- (void)GCDTimer {
    __block NSInteger count = 0;
    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(0.1 * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, start, interval, 0);
    dispatch_source_set_event_handler(timer, ^{
        count++;
        if (count == 10) {
            dispatch_cancel(timer);
            timer = nil;
        }
        NSLog(@"%ld********%@", count, [NSThread currentThread]);
    });
    dispatch_resume(timer);
}

- (void)addTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (void)timerAction:(NSTimer *)timer {
    self.count++;
    if (self.count == 100) {
        [timer invalidate];
        timer = nil;
    }
    NSLog(@"%ld------%@", self.count, [NSThread currentThread]);
}



- (UITableView *)myTableView {
    if (!_myTableView) {
            _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:(UITableViewStylePlain)];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        
    }
    return _myTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString  * const cellid = @"AAAAAAAAAAAAAAA";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellid];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
