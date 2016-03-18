//
//  IBLImageRender.m
//  testgif
//
//  Created by simpossible on 16/1/31.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import "IBLImage.h"
#import "IBLRender.h"


@interface IBLRender ()
@property(nonatomic, weak) IBLImage * iblImage;

@property(nonatomic, assign) NSInteger playTimes; ///<总共需要波昂的次数

@property(nonatomic, assign) NSInteger currentPlayTime;///< 当前播放到第几次了
@end

@implementation IBLRender

- (instancetype)initWithIBLImage:(IBLImage *)image{
    if (self = [super init]) {
        self.iblImage = image;
        _playTimes = -1;
        _currentPlayTime = 0;
    }
    
    return self;
}

- (instancetype)initWithIBLImage:(IBLImage *)image andPlayTimes:(NSInteger)playTimes {
    if (self = [super init]) {
        self.iblImage = image;
        _playTimes = playTimes;
        _currentPlayTime = 0;
    }
    return self;
}

-(void)startRender{
    
    [self.iblImage setImageIndex:self.iblImage.imageIndex];
    
    float time = 0;
    float time1 = [[_iblImage.delayTimes objectAtIndex:_iblImage.imageIndex]floatValue];
    float time2 =[[_iblImage.unclamTimes objectAtIndex:_iblImage.imageIndex]floatValue];
    
    if (time2 != 0) { //两个数组 优先 unclamtimes
        time = time1;
    }else {
        time = time2;
    }
    
    NSInteger cout = _iblImage.imageCount;
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int index  = wself.iblImage.imageIndex +1;
        if (index == cout) {
            wself.currentPlayTime ++;
            if (wself.currentPlayTime == wself.playTimes) {
                [wself.delegate renderComplite];
                return;
            }else {
                [wself.delegate renderEachComplete];
            }
        }
        index = index%cout;
        wself.iblImage.imageIndex = index;
        [wself startRender];
    });
    
}

- (void)dealloc{
    NSLog(@"IBL's render gone");
}
@end
