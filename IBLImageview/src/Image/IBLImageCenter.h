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

/**
 * 根据path 创建
 * 优先搜索缓存里已经存在的
 */
- (IBLImage*)getIBLImageWithPath:(NSString*)path;

/**
 * 手动创建时指定的key值
 */
- (IBLImage*)getIBLImageWithKey:(NSString*)imageKey;

/**
 * 手动创建时指定的key值
 */
- (IBLImage*)getIBLImageWithKey:(NSString*)imageKey andImageArray:(NSArray*)images andDelays:(NSArray*)array;
@end
