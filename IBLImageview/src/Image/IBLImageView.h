//
//  IBLImageView.h
//  testgif
//
//  Created by simpossible on 16/1/28.
//  Copyright © 2016年 simpossible. All rights reserved.
//



#import <UIKit/UIKit.h>

@class IBLImage;
@class GifRender;

@interface UIImageView (IBLImageView)

- (void)setImageWithIBLImage:(IBLImage*)image;

- (void)setImageWithPath:(NSString*)path;

- (void)restartAnimation;

- (void)stopIBLGifPlay;
@end

