//
//  AdView.m
//  ADPager
//
//  Created by lin on 15/8/9.
//  Copyright (c) 2015年 Roy Lin. All rights reserved.
//

#import "ADView.h"
#import "UIImageView+WebCache.h"


static CGFloat ADViewWidth;
static CGFloat ADviewHeight;
static CGFloat MaxLabelLength;

@interface ADView () <UIScrollViewDelegate> {
    
    UIScrollView *_scrollView;
    UIImageView *_leftImageView;
    UIImageView *_centerImageView;
    UIImageView *_rightImageView;
    UIPageControl *_dotsView;
    UILabel *_adTitleLabel;
    
    NSTimer *_scrollTimer;
    
    NSArray *_urlArray;
    NSArray *_titles;
    NSUInteger _leftImageIndex;
    NSUInteger _centerImageIndex;
    NSUInteger _rightImageIndex;

    BOOL _isAutoScroll;

}

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSArray *titles;
@end


@implementation ADView



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        ADViewWidth = _scrollView.bounds.size.width;
        ADviewHeight = _scrollView.bounds.size.height;
        MaxLabelLength = ADViewWidth * 0.6;
        
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentOffset = CGPointMake(ADViewWidth, 0);
        _scrollView.contentSize = CGSizeMake(ADViewWidth * 3, ADviewHeight);
        _scrollView.delegate = self;
        _scrollView.contentInset = UIEdgeInsetsZero;//此语句会影响底部小白点的位置，如果应用上面有导航栏，就执行该语句，否则注释掉即可
        _scrollView.backgroundColor = [UIColor grayColor];
        
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ADViewWidth, ADviewHeight)];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        _leftImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftImageView.clipsToBounds = YES;
        [_scrollView addSubview: _leftImageView];
        
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ADViewWidth, 0, ADViewWidth, ADviewHeight)];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _centerImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _centerImageView.clipsToBounds = YES;
         _centerImageView.userInteractionEnabled = YES;
        [_centerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewItemTap)]];
        [_scrollView addSubview: _centerImageView];
        
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ADViewWidth * 2, 0, ADViewWidth, ADviewHeight)];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightImageView.clipsToBounds = YES;
        [_scrollView addSubview:_rightImageView];
        
        [self addSubview:_scrollView];
        
    }
    return self;
}

#pragma mark - 获取 ADView 实例
+ (instancetype)getADViewWithFrame:(CGRect)frame localImageURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    ADView *adView = [[ADView alloc] initWithFrame:frame];
    if (titles && imageURLs) {
        NSAssert(titles.count == imageURLs.count, @"图片数组的条目和标题数组的不一致");
    } else if (!imageURLs) {
        [NSException raise:@"ADViewInitialization" format:@"图片数组不能为空"];
    } else if (!titles) {
        adView.titles = nil;//清空标题数组
    }
    adView.titles = titles;
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *imageName in imageURLs) {
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        NSAssert(path, @"找不到图片：%@", imageName);
        NSURL *url = [NSURL fileURLWithPath:path];
        [mutableArray addObject: url];
    }
    
    [adView setImageURLs:mutableArray];
    [adView setDotsShowStyle:dotsShowStyle];
    [adView isAutoScroll:YES scrollInterval:3];
    
    return adView;
}

+ (instancetype)getADViewWithFrame:(CGRect)frame imageLinkURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles placeHolderImageName:(NSString *)imageName dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    ADView *adView = [[ADView alloc] initWithFrame:frame];
    if (titles && imageURLs) {
        NSAssert(titles.count == imageURLs.count, @"图片数组的条目和标题数组的不一致");
    } else if (!imageURLs) {
        [NSException raise:@"ADViewInitialization" format:@"图片数组不能为空"];
    } else if (!titles) {
         adView.titles= nil;//清空标题数组
    }
    adView.titles = titles;
    adView.placeholderImage = [UIImage imageNamed:imageName];
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *url in imageURLs) {
        NSURL *networkURL = [NSURL URLWithString:url];
        [mutableArray addObject:networkURL ? networkURL : [NSNull null]];
    }
    [adView setImageURLs:mutableArray];
    [adView setDotsShowStyle:dotsShowStyle];
    [adView isAutoScroll:YES scrollInterval:3];
    return adView;
}

#pragma mark - 阻止使用 init 方法
- (instancetype)init {
    [NSException raise:@"ADViewInitialization" format:@"Use getADViewWithFrame:, not init"];
    return nil;
}



#pragma mark - public
- (void)isAutoScroll:(BOOL)isScroll scrollInterval:(CGFloat)scrollInterval {
    _scrollTime = scrollInterval;
    _isAutoScroll = isScroll;
    if (!isScroll || scrollInterval <= 0) {
        [self setTimer:YES];
        return;
    }
    [self setTimer:NO];
    
}

- (void)setImageURLs:(NSArray *)imageURLs {
    _urlArray = [imageURLs copy];
    _leftImageIndex = _urlArray.count - 1;
    _centerImageIndex = 0;
    _rightImageIndex = 1;
    if (_urlArray.count == 1) {
        _rightImageIndex = 0;
        _scrollView.contentSize = CGSizeMake(ADViewWidth, ADviewHeight);
        [_centerImageView sd_setImageWithURL:_urlArray[_centerImageIndex] placeholderImage:self.placeholderImage];
        [self isAutoScroll:NO scrollInterval:0];
        return;
    }
    [_leftImageView sd_setImageWithURL:_urlArray[_leftImageIndex] placeholderImage:self.placeholderImage];
    [_centerImageView sd_setImageWithURL:_urlArray[_centerImageIndex] placeholderImage:self.placeholderImage];
    [_rightImageView sd_setImageWithURL:_urlArray[_rightImageIndex] placeholderImage:self.placeholderImage];
    if (self.titles) {
        _adTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, MaxLabelLength, 15)];
        _adTitleLabel.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.04 alpha:0.3];
        _adTitleLabel.textColor = [UIColor whiteColor];
        _adTitleLabel.font = [UIFont boldSystemFontOfSize:12];
        _adTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _adTitleLabel.text = _titles[_centerImageIndex];
        [self addSubview:_adTitleLabel];
        [self clipLabelBackground];
    }
    
}

- (void)setDotsShowStyle:(DotsShowStyle)showStyle {
    if (showStyle == DotsShowStyleNone) {
        return;
    }
    _dotsView = [[UIPageControl alloc] init];
    _dotsView.numberOfPages = _urlArray.count;
    
    switch (showStyle) {
        case DotsShowStyleNone:
            return;
            
        case DotsShowStyleLeft:
            _dotsView.frame = CGRectMake(0, ADviewHeight - 20, _dotsView.numberOfPages * 20, 20);
            break;
            
        case DotsShowStyleCenter:
            _dotsView.frame = CGRectMake(0, 0, _dotsView.numberOfPages * 20, 20);
            _dotsView.center = CGPointMake(ADViewWidth / 2.0, ADviewHeight - 20);
            break;
            
        case DotsShowStyleRight:
            _dotsView.frame = CGRectMake(ADViewWidth -  _dotsView.numberOfPages * 20, ADviewHeight - 20, _dotsView.numberOfPages * 20, 20);
            break;
    }

    _dotsView.currentPage = 0;
    _dotsView.enabled = NO;
    [self addSubview:_dotsView];
}

#pragma mark - 设置 _adTitleLabel 的背景宽度
- (void)clipLabelBackground {
    CGRect rect = _adTitleLabel.frame;
    float textLength = _adTitleLabel.intrinsicContentSize.width;
    if (textLength >= MaxLabelLength && rect.size.width != MaxLabelLength) {
        rect.size.width = MaxLabelLength;
        _adTitleLabel.frame = rect;
    } else if (rect.size.width != textLength && textLength < MaxLabelLength) {
        rect.size.width = textLength;
        _adTitleLabel.frame = rect;
    }

}
- (void)setTimer:(BOOL)isDestroy {
    if (!isDestroy) {
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:_scrollTime target:self selector:@selector(timeToScroll) userInfo:nil repeats:YES];

    } else {
        [_scrollTimer invalidate];
        _scrollTimer = nil;
    }
}

- (void)timeToScroll {
    [_scrollView setContentOffset:CGPointMake(ADViewWidth * 2, 0) animated:YES];
    //切换到右边的图片
    [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(scrollViewDidEndDecelerating:) userInfo:nil repeats:NO];
}

- (void)adViewItemTap {
    if (_tapCallBack) {
        _tapCallBack(_centerImageIndex, _urlArray[_centerImageIndex]);
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_scrollView.contentOffset.x == ADViewWidth * 2) {
        
        _leftImageIndex++;
        _centerImageIndex++;
        _rightImageIndex++;
        if (_leftImageIndex == _urlArray.count) {
            _leftImageIndex = 0;
        }
        if (_centerImageIndex == _urlArray.count) {
            _centerImageIndex = 0;
        }
        if (_rightImageIndex == _urlArray.count) {
            _rightImageIndex = 0;
        }
        
    } else if(_scrollView.contentOffset.x == 0) {
        _leftImageIndex--;
        _centerImageIndex--;
        _rightImageIndex--;
        if (_leftImageIndex == -1) {
            _leftImageIndex = _urlArray.count - 1;
        }
        if (_centerImageIndex == -1) {
            _centerImageIndex = _urlArray.count - 1;
        }
        if (_rightImageIndex == -1) {
            _rightImageIndex = _urlArray.count - 1;
        }
    }else {
        return;
    }
    
    [_leftImageView sd_setImageWithURL:_urlArray[_leftImageIndex] placeholderImage:self.placeholderImage];
    [_centerImageView sd_setImageWithURL:_urlArray[_centerImageIndex] placeholderImage:self.placeholderImage];
    [_rightImageView sd_setImageWithURL:_urlArray[_rightImageIndex] placeholderImage:self.placeholderImage];
    
    _dotsView.currentPage = _centerImageIndex;
    _scrollView.contentOffset = CGPointMake(ADViewWidth, 0);
    _adTitleLabel.text = self.titles[_centerImageIndex];
    [self clipLabelBackground];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isAutoScroll) {
        [self setTimer:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isAutoScroll) {
        [self setTimer:NO];
    }
}

@end
