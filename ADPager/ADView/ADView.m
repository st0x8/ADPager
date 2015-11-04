//
//  AdView.m
//  ADPager
//
//  Created by lin on 15/8/9.
//  Copyright (c) 2015年 Roy Lin. All rights reserved.
//
//  https://github.com/st0x8/ADPager
//

#import "ADView.h"
#import "UIImageView+WebCache.h"


static CGFloat ImageViewWidth;
static CGFloat ImageViewHeight;
static CGFloat MaxLabelLength;

@interface ADView () <UIScrollViewDelegate> {
    
    UIScrollView *_scrollView;
    UIImageView *_leftImageView;
    UIImageView *_centerImageView;
    UIImageView *_rightImageView;
    UIPageControl *_dotsView;
    UILabel *_adTitleLabel;
    
    NSUInteger _leftImageIndex;
    NSUInteger _centerImageIndex;
    NSUInteger _rightImageIndex;

}

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSTimer *scrollTimer;
@end

@implementation ADView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        ImageViewWidth = _scrollView.bounds.size.width;
        ImageViewHeight = _scrollView.bounds.size.height;
        MaxLabelLength = ImageViewWidth * 0.6;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentOffset = CGPointMake(ImageViewWidth, 0);
        _scrollView.contentSize = CGSizeMake(ImageViewWidth * 3, ImageViewHeight);
        _scrollView.delegate = self;

        _scrollView.backgroundColor = [UIColor grayColor];
        
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ImageViewWidth, ImageViewHeight)];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        _leftImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftImageView.clipsToBounds = YES;
        [_scrollView addSubview: _leftImageView];
        
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ImageViewWidth, 0, ImageViewWidth, ImageViewHeight)];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _centerImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _centerImageView.clipsToBounds = YES;
        _centerImageView.userInteractionEnabled = YES;
        [_centerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewItemTap)]];
        [_scrollView addSubview: _centerImageView];
        
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ImageViewWidth * 2, 0, ImageViewWidth, ImageViewHeight)];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightImageView.clipsToBounds = YES;
        [_scrollView addSubview:_rightImageView];
        
        [self addSubview:_scrollView];
        
        _autoScroll = YES;
        _scrollInterval = 3;
    }
    return self;
}

#pragma mark - get ADView instance
+ (instancetype)getADViewWithFrame:(CGRect)frame localImageURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    ADView *adView = [[ADView alloc] initWithFrame:frame];
    [adView setLocalImageURLs:imageURLs adTitles:titles dotsShowStyle:dotsShowStyle];
    return adView;
}

+ (instancetype)getADViewWithFrame:(CGRect)frame imageLinkURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles placeHolderImageName:(NSString *)imageName dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    ADView *adView = [[ADView alloc] initWithFrame:frame];
    [adView setImageLinkURLs:imageURLs adTitles:titles placeHolderImageName:imageName dotsShowStyle:dotsShowStyle];
    return adView;
}

#pragma mark - prevent use init method
- (instancetype)init {
    [NSException raise:@"ADViewInitialization" format:@"Use getADViewWithFrame: or initWithFrame: , not init."];
    return nil;
}

#pragma mark - public methods
- (void)setLocalImageURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    if (titles && imageURLs) {
        NSAssert(titles.count == imageURLs.count, @"The imageURLs's count isn't equal to the adTitles'.");
    } else if (!imageURLs || imageURLs.count < 1) {
        [NSException raise:@"ADViewInitialization" format:@"The imageURLs can't be nil and it's count must larger than 1."];
    } else if (!titles) {
        self.titles = nil;//purge title's array
    }
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *imageName in imageURLs) {
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        NSAssert(path, @"Can't find the image：%@", imageName);
        NSURL *url = [NSURL fileURLWithPath:path];
        [mutableArray addObject: url];
    }
    [self setImageURLs:mutableArray adTitles:titles dotsShowStyle:dotsShowStyle];
}

- (void)setImageLinkURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles placeHolderImageName:(NSString *)imageName dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    if (titles && imageURLs) {
        NSAssert(titles.count == imageURLs.count, @"The imageURLs's count isn't equal to the adTitles'.");
    } else if (!imageURLs || imageURLs.count < 1) {
        [NSException raise:@"ADViewInitialization" format:@"The imageURLs can't be nil and it's count must larger than 1."];
    } else if (!titles) {
        self.titles= nil;//purge title's array
    }
    self.titles = [titles copy];
    self.placeholderImage = [UIImage imageNamed:imageName];
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *url in imageURLs) {
        NSURL *networkURL = [NSURL URLWithString:url];
        [mutableArray addObject:networkURL ? networkURL : [NSNull null]];
    }
    [self setImageURLs:mutableArray adTitles:titles dotsShowStyle:dotsShowStyle];
}

- (void)setAutoScroll:(BOOL)autoScroll {
    if (autoScroll && autoScroll != _autoScroll) {
        _autoScroll = autoScroll;
        [self scrollTimer];
    } else if (!autoScroll && autoScroll != _autoScroll) {
        _autoScroll = autoScroll;
        [self destroyTimer];
    }
}

- (void)setScrollInterval:(float)scrollInterval {
    if (_autoScroll && scrollInterval != _scrollInterval) {
        _scrollInterval = scrollInterval;
        [self destroyTimer];
        [self scrollTimer];
    }
}

- (void)setImageURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles dotsShowStyle:(DotsShowStyle)dotsShowStyle {
    self.urlArray = imageURLs;
    self.titles = [titles copy];
    _leftImageIndex = self.urlArray.count - 1;
    _centerImageIndex = 0;
    _rightImageIndex = 1;
    if (self.urlArray.count == 1) {
        _scrollView.contentSize = CGSizeMake(ImageViewWidth, ImageViewHeight);
        [_leftImageView sd_setImageWithURL:self.urlArray[0] placeholderImage:self.placeholderImage];
        _autoScroll = NO;
    } else if (self.urlArray.count > 1){
        [_leftImageView sd_setImageWithURL:self.urlArray[_leftImageIndex] placeholderImage:self.placeholderImage];
        [_centerImageView sd_setImageWithURL:self.urlArray[_centerImageIndex] placeholderImage:self.placeholderImage];
        [_rightImageView sd_setImageWithURL:self.urlArray[_rightImageIndex] placeholderImage:self.placeholderImage];
        
        [self setDotsShowStyle:dotsShowStyle];
        
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
        
        if (self.autoScroll) {
            [self scrollTimer];
        }
        
    }
    
}

- (void)setDotsShowStyle:(DotsShowStyle)showStyle {
    if (showStyle == DotsShowStyleNone) {
        return;
    }
    _dotsView = [[UIPageControl alloc] init];
    _dotsView.numberOfPages = self.urlArray.count;
    
    switch (showStyle) {
        case DotsShowStyleNone:
            return;
            
        case DotsShowStyleLeft:
            _dotsView.frame = CGRectMake(0, ImageViewHeight - 20, _dotsView.numberOfPages * 20, 20);
            break;
            
        case DotsShowStyleCenter:
            _dotsView.frame = CGRectMake(0, 0, _dotsView.numberOfPages * 20, 20);
            _dotsView.center = CGPointMake(ImageViewWidth / 2.0, ImageViewHeight - 20);
            break;
            
        case DotsShowStyleRight:
            _dotsView.frame = CGRectMake(ImageViewWidth -  _dotsView.numberOfPages * 20, ImageViewHeight - 20, _dotsView.numberOfPages * 20, 20);
            break;
    }

    _dotsView.currentPage = _centerImageIndex;
    _dotsView.enabled = NO;
    [self addSubview:_dotsView];
}

#pragma mark - private methods
- (NSTimer *)scrollTimer {
    if (!_scrollTimer) {
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(timeToScroll) userInfo:nil repeats:YES];
    }
    return _scrollTimer;
}

- (void)destroyTimer{
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

- (void)timeToScroll {
    [_scrollView setContentOffset:CGPointMake(ImageViewWidth * 2, 0) animated:YES];
    
}

- (void)scrollToRight:(BOOL)isRight {
    if (isRight) {
        
        _leftImageIndex++;
        _centerImageIndex++;
        _rightImageIndex++;
        if (_leftImageIndex == self.urlArray.count) {
            _leftImageIndex = 0;
        }
        if (_centerImageIndex == self.urlArray.count) {
            _centerImageIndex = 0;
        }
        if (_rightImageIndex == self.urlArray.count) {
            _rightImageIndex = 0;
        }
        
    } else {
        _leftImageIndex--;
        _centerImageIndex--;
        _rightImageIndex--;
        if (_leftImageIndex == -1) {
            _leftImageIndex = self.urlArray.count - 1;
        }
        if (_centerImageIndex == -1) {
            _centerImageIndex = self.urlArray.count - 1;
        }
        if (_rightImageIndex == -1) {
            _rightImageIndex = self.urlArray.count - 1;
        }
    }
    
    [_leftImageView sd_setImageWithURL:self.urlArray[_leftImageIndex] placeholderImage:self.placeholderImage];
    [_centerImageView sd_setImageWithURL:self.urlArray[_centerImageIndex] placeholderImage:self.placeholderImage];
    [_rightImageView sd_setImageWithURL:self.urlArray[_rightImageIndex] placeholderImage:self.placeholderImage];
    
    _dotsView.currentPage = _centerImageIndex;
    _scrollView.contentOffset = CGPointMake(ImageViewWidth, 0);
    _adTitleLabel.text = self.titles[_centerImageIndex];
    [self clipLabelBackground];
}


//Set _adTitleLabel's backgound dynamically.
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

- (void)adViewItemTap {
    if (_tapCallBack) {
        _tapCallBack(_centerImageIndex, self.urlArray[_centerImageIndex]);
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_scrollView.contentOffset.x == ImageViewWidth * 2) {
        [self scrollToRight:YES];
    } else if(_scrollView.contentOffset.x == 0) {
        [self scrollToRight:NO];
    }else {
        return;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScroll) {
        [self destroyTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self scrollTimer];
    }
}

//Tells the delegate when a scrolling animation in the scroll view concludes.This method call after send "setContentOffset: animated:".
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollToRight:YES];
}

@end
