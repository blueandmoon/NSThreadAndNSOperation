//
//  ViewController.m
//  NSThreadAndNSOperation
//
//  Created by 李根 on 16/7/7.
//  Copyright © 2016年 ligen. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()
@property(nonatomic, strong)UIImageView *imageView;

@end

void * run(void *param) {
    for (NSInteger i = 0; i < 1000; i++) {
        NSLog(@"---ButtonClick---%zd---%@", i, [NSThread currentThread]);
    }
    return NULL;
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
#pragma mark    - pthread
    //  Pthread 一套通用的多线程API
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.view addSubview:btn];
//    btn.frame = CGRectMake(100, 200, 100, 50);
//    btn.backgroundColor = [UIColor purpleColor];
//    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
#pragma mark    - NSThread
    //  第一种方式: 先创建再启动线程
//    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:@"jack"];
//    [thread start]; //  线程启动了, 事情做完了才会死, 一个NSThread对象就代表一条线程
    
    //  第二种方式: 直接创建并启动线程
//    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"jack"];
    
    //  第三种: 直接创建并启动线程
//    [self performSelectorInBackground:@selector(run:) withObject:@"jack"];
//    //  使线程进入阻塞状态
//    [NSThread sleepForTimeInterval:2.0];
    
    
#pragma mark    - 线程间通讯, 下载完图片刷新
    //  监听线程结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_threadexit:) name:NSThreadWillExitNotification object:nil];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //  下载图片刷新
    NSURL *url = [NSURL URLWithString:@"https://pages.github.com/images/slideshow/yeoman.png"];
    //  另开一条线程, object用于数据的传递
    NSThread *thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(downLoadWithURL:) object:url];
    thread3.name = @"downLoadImage...";
    //  由于下载图片的耗时太长, 应开启线程来完成
    [thread3 start];
}

- (void)downLoadWithURL:(NSURL *)url {
    NSLog(@"%s, %s, %@", __FILE__, __FUNCTION__, [NSThread currentThread]);
    //  下载图片
    NSData *data = [NSData dataWithContentsOfURL:url];
    //  生成图片
    UIImage *image = [UIImage imageWithData:data];
    //  返回主线程显示图片
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
}

- (void)handle_threadexit:(NSNotification *)notify {
    NSThread *thread = (NSThread *)notify.object;
    NSLog(@"+++++线程 %@ 结束++++++", thread.name);
}

- (UIImageView *)imageView {
    if (!_imageView) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//        });
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
            _imageView.backgroundColor = [UIColor purpleColor];
            _imageView.center = self.view.center;
            [self.view addSubview:_imageView];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
    }
    return _imageView;
}

//      -----------分割线------------------
- (void)run:(NSString *)param {
    //  当前线程是否是主线程
    for (NSInteger i = 0; i < 100; i++) {
        NSLog(@"---%@---%zd---%d", [NSThread currentThread], i, [NSThread isMainThread]);
    }
}

- (void)click:(id)sender {
    
    // 定义一个线程
    pthread_t thread;
    // 创建一个线程  (参1)pthread_t *restrict:创建线程的指针，(参2)const pthread_attr_t *restrict:线程属性  (参3)void *(*)(void *):线程执行的函数的指针，(参4)void *restrict:null
    pthread_create(&thread, NULL, run, NULL);
    // 何时回收线程不需要你考虑
    pthread_t thread2;
    pthread_create(&thread2, NULL, run, NULL);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
