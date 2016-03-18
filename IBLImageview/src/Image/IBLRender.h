//
//  IBLImageRender.h
//  testgif
//
//  Created by simpossible on 16/1/31.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBLImage;

@protocol IBLRenderDelegate <NSObject>

/**播放次数结束*/
- (void)renderComplite;

/**每次播放结束回调*/
- (void)renderEachComplete;

@end

@interface IBLRender : NSObject

@property(nonatomic, weak)id<IBLRenderDelegate> delegate;

- (instancetype)initWithIBLImage:(IBLImage*)image;

- (instancetype)initWithIBLImage:(IBLImage *)image andPlayTimes:(NSInteger)playTimes;

-(void)startRender;
@end
