//
//  AdView.h
//  ADPager
//
//  Created by lin on 15/8/9.
//  Copyright (c) 2015年 Roy Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @author Roy Lin
 *
 *  底部小白点的显示位置。
 */
typedef NS_ENUM(NSUInteger, DotsShowStyle){
    /**
     *  @author Roy Lin
     *
     *  不显示
     */
    DotsShowStyleNone,
    /**
     *  @author Roy Lin
     *
     *  靠左
     */
    DotsShowStyleLeft,
    /**
     *  @author Roy Lin
     *
     *  居中
     */
    DotsShowStyleCenter,
    /**
     *  @author Roy Lin
     *
     *  靠右
     */
    DotsShowStyleRight,
};

@interface ADView : UIView {
    
    CGFloat _scrollTime;
}

/**
 *  @author Roy Lin
 *
 *  点击回调
 */
@property (nonatomic, strong) void (^tapCallBack)(NSInteger currentIndex, NSURL *imgURL);


/**
 *  @author Roy Lin
 *
 *  创建显示网络图片的ADView
 *
 *  @param frame         set Frame
 *  @param imageURLs     设置图片链接数组
 *  @param adTitles      设置各图片标题（ nil 值不显示标题）
 *  @param imageName     设置图片获取前及获取失败时的占位图片
 *  @param dotsShowStyle 设置底部小白点的显示位置
 *
 *  @return 返回 ADView 实例
 */
+ (id)getADViewWithFrame: (CGRect)frame imageLinkURLs: (NSArray *)imageURLs adTitles: (NSArray *)titles placeHolderImageName: (NSString *)imageName dotsShowStyle: (DotsShowStyle)dotsShowStyle;

/**
 *  @author Roy Lin
 *
 *  创建显示本地图片的ADView
 *
 *  @param frame         set Frame
 *  @param imageURLs     设置本地图片名称数组(避免存在同名的图片,并在图片名后加上后缀名）
 *  @param adTitles      设置各图片标题 （nil 值不显示标题）
 *  @param dotsShowStyle 设置底部小白点的显示位置
 *
 *  @return 返回 ADView 实例
 */
+ (id)getADViewWithFrame: (CGRect)frame localImageURLs: (NSArray *)imageURLs adTitles: (NSArray *)titles dotsShowStyle: (DotsShowStyle)dotsShowStyle;

/**
 *  @author Roy Lin
 *
 *  是否开启自动轮播及开启后的间隔时间
 *
 *  @param isScroll       是否开启
 *  @param scrollInterval 轮播间隔
 */
- (void)isAutoScroll:(BOOL)isScroll scrollInterval:(CGFloat)scrollInterval;
@end
