//
//  ViewController.m
//  HBK_Timer
//
//  Created by 黄冰珂 on 2018/5/29.
//  Copyright © 2018年 KK. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_queue_t queue = dispatch_queue_create("aaa", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self addTimer];
    });
    dispatch_async(queue, ^{
        [self GCDTimer];
    });
    
}
- (void)GCDTimer {
    __block NSInteger count = 0;
    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(0.2 * NSEC_PER_SEC);
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
    if (self.count == 10) {
        [timer invalidate];
        timer = nil;
    }
    NSLog(@"%ld------%@", self.count, [NSThread currentThread]);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
