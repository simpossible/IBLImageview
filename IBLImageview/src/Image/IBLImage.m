//
//  IBLImage.m
//  testgif
//
//  Created by simpossible on 16/1/28.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import "IBLImage.h"
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>
#import "IBLRender.h"

@interface IBLImage ()
@property(nonatomic, copy)NSString * path;
@property(nonatomic, strong)NSMutableArray *renders;

@property(nonatomic, strong)IBLRender *render;
@end

@implementation IBLImage

- (instancetype)initWithPath:(NSString *)path{
    if (self = [super init]) {
        if (path) {
            self.path = path;
        }else{
            self.path = @"";
        }
    }
    
    _images = [NSMutableArray array];
    _unclamTimes = [NSMutableArray array];
    _delayTimes = [NSMutableArray array];
    _renders = [NSMutableArray array];
    _needRender = NO;
    [self CreateCGImagesFormPath];
    return self;
}


- (void)CreateCGImagesFormPath{
    NSURL *fileUrl = [NSURL fileURLWithPath:self.path];
    CFURLRef cfFileUrl = (__bridge CFURLRef)fileUrl;
    
    CFDictionaryRef params = NULL;
    
    CFStringRef myKeys[2];
    CFTypeRef  myValue[2];
    
    myKeys[0] = kCGImageSourceShouldCache;
    myValue[0] = (CFTypeRef)kCFBooleanTrue;
    
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValue[1] = (CFTypeRef)kCFBooleanTrue;
    
    params = CFDictionaryCreate(NULL, (const void **)myKeys, (const void **)myValue, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CGImageSourceRef pictureSource = CGImageSourceCreateWithURL(cfFileUrl, params);
    
    size_t t = CGImageSourceGetCount(pictureSource);
    
    _imageCount = (NSInteger)t;
    
    if (t>1) {
        for (int i = 0; i<t; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(pictureSource, i, params);
            UIImage *nowImage = [[UIImage alloc]initWithCGImage:image];
            [_images addObject:nowImage];
            CFRelease(image);
        }
    }else{
        CGImageRef image = CGImageSourceCreateImageAtIndex(pictureSource, 0, params);
        UIImage *nowImage = [[UIImage alloc]initWithCGImage:image];
        [_images addObject:nowImage];
        CFRelease(image);
    }
    
    [self initialDelaytimesWithImageSource:pictureSource];
    
    CFRelease(params);
    CFRelease(pictureSource);
         
}

- (void)initialDelaytimesWithImageSource:(CGImageSourceRef)src{
    for (int i = 0 ; i<_imageCount; i++) {
        CFDictionaryRef property = CGImageSourceCopyPropertiesAtIndex(src, i, NULL);
        
        NSDictionary *dic = (__bridge_transfer NSDictionary*)property;
        
        NSString *gifDicKey = (NSString*)kCGImagePropertyGIFDictionary;
        NSString *gifDelayKey = (NSString*)kCGImagePropertyGIFDelayTime;
        NSString *gifUndeleykey = (NSString*)kCGImagePropertyGIFUnclampedDelayTime;
        
        NSDictionary *delayTimeDic = [dic objectForKey:gifDicKey];
        NSNumber *deleaytime;
        NSNumber *unClamDelaytime;
        if (delayTimeDic) {
            deleaytime = [delayTimeDic objectForKey:gifDelayKey];
            unClamDelaytime = [delayTimeDic objectForKey:gifUndeleykey];
            
            [_delayTimes addObject:deleaytime];
            [_unclamTimes addObject:unClamDelaytime];
        }
        
    }
    NSLog(@"delayTimes:%@",_delayTimes);
    NSLog(@"unclamTime:%@",_unclamTimes);
    
}

//- (void)test{
//    CFArrayRef array =  CGImageSourceCopyTypeIdentifiers();
//    CFArrayRef desArray = CGImageDestinationCopyTypeIdentifiers();
//    NSLog(@"the array is %@",array);
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"gif"];
//    NSURL *fileUrl = [NSURL fileURLWithPath:path];
//    
//    CFURLRef gifurl = (__bridge CFURLRef)(fileUrl);
//    CFDictionaryRef param = (__bridge CFDictionaryRef)(@{(__bridge NSString*)kCGImageSourceThumbnailMaxPixelSize:@(0)});
//    CGImageSourceRef gifSource= CGImageSourceCreateWithURL(gifurl, param);
//    size_t t= CGImageSourceGetCount(gifSource);
//    
//    CFDictionaryRef dictionary = nil;
//    
//    for (size_t i = 0 ; i<t; i++) {
//       CFDictionaryRef property = CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
//        
//        NSDictionary *dic = (__bridge_transfer NSDictionary*)property;
//        NSLog(@"%@",dic);
//        CFRelease(property);
//    }
//    
//}

- (void)addDelegates:(id<IBLImageRenderDelegate>)delegate{
    if (![_renders containsObject:delegate]) {
        [_renders addObject:delegate];
    }
    if (!_needRender) {
        self.needRender = YES;
        [self startRender];
    }
}

- (void)removeDelegate:(id<IBLImageRenderDelegate>)delegate{
    if ([_renders containsObject:delegate]) {
        [_renders removeObject:delegate];
    }
    if (_renders.count == 0) {
        [self stopRender];
    }
}

- (void)setImageIndex:(int)imageIndex{
    if (imageIndex<_imageCount && imageIndex >=0) {
        _imageIndex = imageIndex;
        
        for (id<IBLImageRenderDelegate> delegate in _renders) {
            if ([delegate respondsToSelector:@selector(torenderImage:)]) {
                [delegate torenderImage:[_images objectAtIndex:imageIndex]];
            }
        }
    }
    
}

-(void)startRender{
    if (self.render) {
        return;
    }
    self.imageIndex = 0;
    self.render = [[IBLRender alloc]initWithIBLImage:self];
    [self.render startRender];
}

- (void)stopRender{
    self.render = nil;
    self.imageIndex = 0;
}


- (void)beconListenr{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reRender) name:kIBL_IMG_RE_ANIMATE object:nil];
}

- (void)resignListener{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kIBL_IMG_RE_ANIMATE];
}

- (void)reRender{
    [self stopRender];
    [self startRender];
}

- (void)setNeedRender:(BOOL)needRender{
    if (needRender == _needRender) {
        return;
    }
    if (needRender) {
        _needRender = YES;
        [self beconListenr];
    }else{
        _needRender = NO;
        [self resignListener];
    }
}
@end
