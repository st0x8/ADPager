//
//  ViewController.m
//  ADPager
//
//  Created by lin on 15/8/8.
//  Copyright (c) 2015年 Roy Lin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect windowFrame = [[UIScreen mainScreen] applicationFrame];

    UILabel *localLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 38, windowFrame.size.width * 0.5, 15)];
    localLabel.text = @"本地图片：";
    [self.view addSubview:localLabel];
    
    NSArray *localImages = @[@"Image0.jpg", @"Image1.jpg", @"Image2.jpg", @"Image3.jpg"];
    NSArray *titles = @[@"Title0", @"Title two", @"This is another title!", @"Title four"];
    NSArray *webImages = @[@"http://upload-images.jianshu.io/upload_images/712713-33675c0b9adbce3e.jpg",
                           @"http://upload-images.jianshu.io/upload_images/102650-ee85e28f5f1ce2e3.jpg",
                           @"null",
                           @"null"];
    
    ADView *adView = [ADView getADViewWithFrame:CGRectMake(0, 55, windowFrame.size.width, windowFrame.size.height * 0.35) localImageURLs:localImages adTitles:titles dotsShowStyle:DotsShowStyleCenter];
    [self.view addSubview:adView];
    //[adView isAutoScroll:NO scrollInterval:0];
    adView.tapCallBack = ^ (NSInteger currentIndex, NSURL *imageURL) {
        NSLog(@"%ld %@", (long)currentIndex, imageURL);
    };
    
    UILabel *webLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, windowFrame.size.height - windowFrame.size.height * 0.35 - 22, windowFrame.size.width, 15)];
    webLabel.text = @"网络图片：";
    [self.view addSubview:webLabel];
                           
    ADView *webADView = [ADView getADViewWithFrame:CGRectMake(0, windowFrame.size.height - 5 - windowFrame.size.height * 0.35, windowFrame.size.width, windowFrame.size.height * 0.35) imageLinkURLs:webImages adTitles:titles placeHolderImageName:@"rabbit.jpg" dotsShowStyle:DotsShowStyleLeft];
    [webADView isAutoScroll:NO scrollInterval:0];//关闭自动轮播
    [self.view addSubview:webADView];
    webADView.tapCallBack = ^(NSInteger currentIndex, NSURL *imageURL){
        NSLog(@"%ld %@", (long)currentIndex, imageURL);
    };

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
