//
//  IBLImageView.m
//  testgif
//
//  Created by simpossible on 16/1/28.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import "IBLImageView.h"
#import "IBLImage.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "IBLImageCenter.h"

@interface UIImageView()<IBLImageRenderDelegate>

@property(nonatomic, weak) IBLImage *iblImage;

@property(nonatomic, strong) IBLImage * retainImage; ///< 这个imgae 对象不再center 中进行保存 进行强引用
@end

@implementation UIImageView(IBLImageView)


- (IBLImage *)iblImage{
 return objc_getAssociatedObject(self, @selector(iblImage));
}

-(void)setIblImage:(IBLImage *)iblImage{
 objc_setAssociatedObject(self, @selector(iblImage), iblImage, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setImageWithIBLImage:(IBLImage *)image{
    [image addDelegates:self];
}


- (IBLImage *)retainImage {
    return objc_getAssociatedObject(self, @selector(retainImage));
}

- (void)setRetainImage:(IBLImage *)image {
    objc_setAssociatedObject(self, @selector(retainImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark 入口方法(entrance method) -

/**设置 gif 通过 path*/
- (void)setImageWithPath:(NSString *)path {
    
    if ([self isPathIlleagle:path]) {
        IBLImage *image = [[IBLImageCenter sharedCenter]getIBLImageWithPath:path];
        if (image) {
            if (image.imageCount > 1) {
                [image addDelegates:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:kIBL_IMG_RE_ANIMATE object:nil];
            }else if(image.imageCount == 1){
                [self setImage:image.images[0]];
            }else{
                NSLog(@"IBL:多图获取失败");
            }
        }else{
            NSLog(@"IBL:获取的图片为空");
        }
    }
}

- (void)setImageWithPath:(NSString *)path andEveryPlay:(void (^)(int times))everyCallback {
    if ([self isPathIlleagle:path]) {
        IBLImage *image = [[IBLImageCenter sharedCenter]getIBLImageWithPath:path ];
        [image setEveryPlayCallBack:everyCallback];
        if (image) {
            if (image.imageCount > 1) {
                [image addDelegates:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:kIBL_IMG_RE_ANIMATE object:nil];
            }else if(image.imageCount == 1){
                [self setImage:image.images[0]];
            }else{
                NSLog(@"IBL:多图获取失败");
            }
        }else{
            NSLog(@"IBL:获取的图片为空");
        }
    }
}

/**设置gif */
- (void)setImageWithPath:(NSString *)path recycleTime:(NSInteger)times andCompleteCallBack:(void (^)())callback {
    if ([self isPathIlleagle:path]) {
        IBLImage *image = [[IBLImage alloc]initWithPath:path playTimes:times andCallBack:callback];
        self.retainImage = image;
        if (image) {
            if (image.imageCount > 1) {
                [image addDelegates:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:kIBL_IMG_RE_ANIMATE object:nil];
            }else if(image.imageCount == 1){
                [self setImage:image.images[0]];
            }else{
                NSLog(@"IBL:多图获取失败");
            }
        }else {
            NSLog(@"IBL:无法获取gif");
        }
    }
}


- (void)setImageWithPath:(NSString *)path recycleTime:(NSInteger)times andCompleteCallBack:(void (^)())callback andeveryPlay:(void (^)(int times))everyCallback {
    if ([self isPathIlleagle:path]) {
        IBLImage *image = [[IBLImage alloc]initWithPath:path playTimes:times andCallBack:callback andeveryPlay:everyCallback];
        self.retainImage = image;
        if (image) {
            if (image.imageCount > 1) {
                [image addDelegates:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:kIBL_IMG_RE_ANIMATE object:nil];
            }else if(image.imageCount == 1){
                [self setImage:image.images[0]];
            }else{
                NSLog(@"IBL:多图获取失败");
            }
        }else {
            NSLog(@"IBL:无法获取gif");
        }
    }
}

- (void)gifToChangePicture:(UIImage *)image{
    if (!image) {
        return;
    }
    [self setImage:image];
}

- (BOOL)isPathIlleagle:(NSString *)path {
    if (!path || [path isEqualToString:@""]) {
        NSLog(@"IBL:空路径无法获取图片");
        return NO;
    }
    return YES;
}

- (void)restartAnimation{

}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma mark util -

- (void)torenderImage:(UIImage *)image{
    if (image) {
        [self setImage:image];
    }
}
#pragma clang diagnostic pop

- (void)stopIBLGifPlay{
    [self.iblImage removeDelegate:self];
    [self setImage:self.iblImage.images[0]];

}

- (void)dealloc{
    [self.iblImage removeDelegate:self];
}
@end
