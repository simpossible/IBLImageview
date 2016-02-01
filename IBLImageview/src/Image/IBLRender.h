//
//  IBLImageRender.h
//  testgif
//
//  Created by simpossible on 16/1/31.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBLImage;
@interface IBLRender : NSObject

- (instancetype)initWithIBLImage:(IBLImage*)image;

-(void)startRender;
@end
