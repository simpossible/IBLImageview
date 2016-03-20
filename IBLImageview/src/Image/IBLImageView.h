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

/**需要先 获得一个IBL IMage 
 * 不建议使用
 */
- (void)setImageWithIBLImage:(IBLImage*)image;

/**播放 gif 以本地路径 默认无限循环
 * 每次新增的时候 都会将 所有的gif 从头开始播放 以达到 qq 表情的效果
 */
- (void)setImageWithPath:(NSString*)path;

/**每次播放完毕的回调
* @param everyCallback 每一次播放完毕的回调
*/
- (void)setImageWithPath:(NSString*)path andeveryPlay:(void (^)())everyCallback;;

/**播放 gif 以本地路径
 * @param times 播放的次数
 * @param callback 播放完成时的回调 切忌循环引用
 * 拥有单独的播放进程 不会 进行同步
 */
- (void)setImageWithPath:(NSString *)path recycleTime:(NSInteger)times andCallBack:(void (^)())callback;

/**播放 gif 以本地路径
 * @param times 播放的次数
 * @param callback 播放完成时的回调 切忌循环引用
 * @param everyCallback 每一次播放完毕的回调
 * 拥有单独的播放进程 不会 进行同步
 */
- (void)setImageWithPath:(NSString *)path recycleTime:(NSInteger)times andCallBack:(void (^)())callback andeveryPlay:(void (^)())everyCallback;

/**重新播放gif*/
- (void)restartAnimation;

- (void)stopIBLGifPlay;
@end

