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
@property(nonatomic, weak)IBLImage *iblImage;
@end

@implementation IBLRender

- (instancetype)initWithIBLImage:(IBLImage *)image{
    if (self = [super init]) {
        self.iblImage = image;
    }
    
    return self;
}

-(void)startRender{
    
    [self.iblImage setImageIndex:self.iblImage.imageIndex];
    
    float time = [[_iblImage.delayTimes objectAtIndex:_iblImage.imageIndex]floatValue];
    NSInteger cout = _iblImage.imageCount;
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int index  = wself.iblImage.imageIndex +1;
        index = index%cout;
        wself.iblImage.imageIndex = index;
        [wself startRender];
    });
    
}

- (void)dealloc{
    NSLog(@"IBL's render gone");
}
@end
