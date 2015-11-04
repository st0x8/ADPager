//
//  AdView.h
//  ADPager
//
//  Created by lin on 15/8/9.
//  Copyright (c) 2015年 Roy Lin. All rights reserved.
//
//  https://github.com/st0x8/ADPager
//

#import <UIKit/UIKit.h>

/**
 *  @author Roy Lin
 *
 *  Where the bottom white dots show
 */
typedef NS_ENUM(NSUInteger, DotsShowStyle){
    /**
     *
     *  Don't show
     */
    DotsShowStyleNone,
    /**
     *
     *  Be left
     */
    DotsShowStyleLeft,
    /**
     *
     *  Be center
     */
    DotsShowStyleCenter,
    /**
     *
     *  Be right
     */
    DotsShowStyleRight,
};

@interface ADView : UIView

@property (nonatomic) BOOL autoScroll;

/**
 *  @brief  Auto scroll interval time. The value(second) just can change which autoScroll is Yes.
 */
@property (nonatomic) float scrollInterval;

/**
 *
 *  Tap event callback
 */
@property (nonatomic, strong) void(^tapCallBack)(NSInteger currentIndex, NSURL *imgURL);

/**
 *
 *  Class method, create ADView instance to display network images and set images' url and titles.
 *
 *  @param frame         set Frame
 *  @param imageURLs     set image link URL' array
 *  @param adTitles      set each image display title（ set nil to hide the title）
 *  @param imageName     UIImage to set on the view while the image at URL is being retrieved, If retrieved failure, the image will not be replaced.
 *  @param dotsShowStyle where the bottom white dots show
 *
 *  @return ADView instance
 */
+ (id)getADViewWithFrame:(CGRect)frame imageLinkURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles placeHolderImageName:(NSString *)imageName dotsShowStyle:(DotsShowStyle)dotsShowStyle;

/**
 *
 *  Class method, create ADView instance to display local images  and set images' name and titles.
 *
 *  @param frame         set Frame
 *  @param imageURLs     set local image URL' array (presevent set the same name image, which image name must add suffix）
 *  @param adTitles      set each image display title（ set nil to hide the title）
 *  @param dotsShowStyle where the bottom white dots show
 *
 *  @return ADView instance
 */
+ (id)getADViewWithFrame:(CGRect)frame localImageURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles dotsShowStyle:(DotsShowStyle)dotsShowStyle;

/**
 *  @brief  Set images' URL and titles after create instantce use @cinitWithFrame:;
 *  @param imageName     UIImage to set on the view while the image at URL is being retrieved, If retrieved failure, the image will not be replaced.
 *
 */
- (void)setImageLinkURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles placeHolderImageName:(NSString *)imageName dotsShowStyle:(DotsShowStyle)dotsShowStyle;

/**
 *  @brief  Set local images' name and titles after create instantce use @cinitWithFrame:;
 *
 */
- (void)setLocalImageURLs:(NSArray *)imageURLs adTitles:(NSArray *)titles dotsShowStyle: (DotsShowStyle)dotsShowStyle;

@end
