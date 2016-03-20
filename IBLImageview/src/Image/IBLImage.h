//
//  IBLImage.h
//  testgif
//
//  Created by simpossible on 16/1/28.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IBLGifImageViewDefine.h"

@protocol IBLImageRenderDelegate <NSObject>

- (void)torenderImage:(UIImage *)image;

@end

@interface IBLImage : NSObject

@property(nonatomic, assign)BOOL needRender;

/**
 * 当前的所有图片
 */
@property(nonatomic, strong, readonly)NSMutableArray * images;

/**
 * 当前的所有图片 的播放时间
 */
@property(nonatomic, strong, readonly)NSMutableArray * unclamTimes;

/**
 * 当前的所有图片 的播放时间
 */
@property(nonatomic, strong, readonly)NSMutableArray * delayTimes;

/**
 * 当前所包含的图片的个数
 */
@property(nonatomic, assign, readonly)NSInteger   imageCount;

/**gif 的播放次数 */
@property(nonatomic, assign, readonly)NSInteger playTimes;

@property(nonatomic, assign)int imageIndex;


- (instancetype)initWithPath:(NSString *)path;

- (instancetype)initWithPath:(NSString *)path andeveryPlay:(void (^)())everyCallback;

- (instancetype)initWithPath:(NSString *)path playTimes:(NSInteger)playtime andCallBack:(void (^)())callback;

- (instancetype)initWithPath:(NSString *)path playTimes:(NSInteger)playtime andCallBack:(void (^)())callback andeveryPlay:(void (^)())everyCallback;

//todo 根据多图 和每一帧的时间长度 播放
- (instancetype)initWithImagesArray:(NSArray *)images andClamTimesArray:(NSArray *)clams;


- (void)setEveryPlayCallBack:(void (^)())callback;

//- (void)test;

- (void)addDelegates:(id<IBLImageRenderDelegate>)delegate;

- (void)removeDelegate:(id<IBLImageRenderDelegate>)delegate;

- (void)stopRender;

@end
