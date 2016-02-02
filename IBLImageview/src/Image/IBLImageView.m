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

@property(nonatomic, weak)IBLImage *iblImage;
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

- (void)setImageWithPath:(NSString *)path{
    
    if (!path) {
        NSLog(@"IBL:空路径无法获取图片");
        return;
    }
    
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


- (void)gifToChangePicture:(UIImage *)image{
    if (!image) {
        return;
    }
    [self setImage:image];
}



- (void)restartAnimation{

}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)torenderImage:(UIImage *)image{
    if (image) {
        [self setImage:image];
    }
}
#pragma clang diagnostic pop

- (void)dealloc{
    [self.iblImage removeDelegate:self];
}
@end
