//
//  IBLImageCenter.h
//  testgif
//
//  Created by simpossible on 16/1/31.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IBLImage;
@interface IBLImageCenter : NSObject

+ (IBLImageCenter*)sharedCenter;

/**通过该方法获得的image 对象 会同步播放*/
- (IBLImage *)getIBLImageWithPath:(NSString*)path;

/**该方法会 获得单独的image*/
- (IBLImage *)getIBLImageWithPath:(NSString *)path andPlayTimes:(NSInteger *)times andCallback:(void (^)())succ;
@end
