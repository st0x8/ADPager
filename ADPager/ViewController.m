//
//  ViewController.m
//  ADPager
//
//  Created by lin on 15/8/8.
//  Copyright (c) 2015年 Roy Lin. All rights reserved.
//

#import "ViewController.h"
#import "AdView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    
    UILabel *localLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 84, windowFrame.size.width * 0.5, 15)];
    localLabel.text = @"Local:";
    [self.view addSubview:localLabel];
    
    NSArray *localImages = @[@"Image0.jpg", @"Image1.jpg", @"Image2.jpg", @"Image3.jpg"];
    NSArray *titles = @[@"Title one", @"This is another title!", @"Note the placeholder", @"Note the white dots position"];
    NSArray *webImages = @[@"http://img02.tooopen.com/images/20140702/sl_79571073169.jpg",
                           @"http://img05.tooopen.com/images/20140612/sl_77081335958.jpg",
                           @"null",
                           @"http://img05.tooopen.com/images/20140612/sl_77091426278.jpg"];
    ADView *adView = [ADView getADViewWithFrame:CGRectMake(0, 100, windowFrame.size.width, windowFrame.size.height * 0.35) localImageURLs:localImages adTitles:titles dotsShowStyle:DotsShowStyleCenter];
    
//    ADView *adView = [ADView getADViewWithFrame:CGRectMake(0, 100, windowFrame.size.width, windowFrame.size.height * 0.35) localImageURLs:@[@"Image0.jpg"] adTitles:@[@"Image0.jpg"] dotsShowStyle:DotsShowStyleCenter];
    [self.view addSubview:adView];
    adView.scrollInterval = 3;
    adView.tapCallBack = ^ (NSInteger currentIndex, NSURL *imageURL) {
        NSLog(@"%ld %@", (long)currentIndex, imageURL);
    };
    
    UILabel *webLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, windowFrame.size.height - windowFrame.size.height * 0.35 - 22, windowFrame.size.width, 15)];
    webLabel.text = @"Network:";
    [self.view addSubview:webLabel];
    
    ADView *webADView = [ADView getADViewWithFrame:CGRectMake(0, windowFrame.size.height - 5 - windowFrame.size.height * 0.35, windowFrame.size.width, windowFrame.size.height * 0.35) imageLinkURLs:webImages adTitles:titles placeHolderImageName:@"rabbit.jpg" dotsShowStyle:DotsShowStyleLeft];
    webADView.autoScroll = NO;//Close auto scroll
    [self.view addSubview:webADView];
    webADView.tapCallBack = ^(NSInteger currentIndex, NSURL *imageURL){
        NSLog(@"Tap the image: %ld >>> %@", (long)currentIndex, imageURL);
    };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
