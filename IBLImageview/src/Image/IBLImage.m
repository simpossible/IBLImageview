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

#import "IBLGifImageViewDefine.h"

@interface IBLImage ()<IBLRenderDelegate>
@property(nonatomic, copy)NSString * path;
@property(nonatomic, strong)NSMutableArray *renders; ///< 所有被渲染的imageview

@property(nonatomic, strong, setter=setRender:)IBLRender *render;

@property(nonatomic, copy)void (^completeCallback)();///< 播放完成的回调

@property(nonatomic, copy)void (^eachTimeCallBack)();///< 每一次播放完成的回调

@property(nonatomic, assign)IBLImageType imageType;
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
    
    [self initialDatas];
    _imageType = IBLImageTypeRenderAllTheTime;
    return self;
}

- (instancetype)initWithPath:(NSString *)path playTimes:(NSInteger)playtime andCallBack:(void (^)())callback {
    if (self = [super init]) {
        if (path) {
            self.path = path;
        }else{
            self.path = @"";
        }

    }
    [self initialDatas];
    _playTimes =  playtime;
    _completeCallback = callback;
    _imageType = IBLImageTypeRenderWithTImes;
    return self;
}

- (void)initialDatas {
    _images = [NSMutableArray array];
    _unclamTimes = [NSMutableArray array];
    _delayTimes = [NSMutableArray array];
    _renders = [NSMutableArray array];
    _needRender = NO;
    [self CreateCGImagesFormPath];
}


#pragma mark datasource(数据初始化) -

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


- (void)addDelegates:(id<IBLImageRenderDelegate>)delegate{
    if (![_renders containsObject:delegate]) {
        [_renders addObject:delegate];
    }
    if (self.imageType == IBLImageTypeRenderAllTheTime) {
        if (!_needRender) {
            self.needRender = YES; ///会开启监听
            [self startRender];
        }
    } else if (self.imageType == IBLImageTypeRenderWithTImes) {
        if (!_needRender) {
            [self startRender];    /// 不能开启监听
        }
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


// 遍历渲染 imageview

/**渲染其所有的image*/
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

/**开始渲染*/
-(void)startRender{
    if (self.render) {
        return;
    }
    self.imageIndex = 0;
    self.render = [[IBLRender alloc]initWithIBLImage:self];
    [self.render startRender];
}

/**停止渲染*/
- (void)stopRender{
    self.render = nil;
    self.imageIndex = 0;
}

/**这个监听 可以让所有的imageview 重新渲染*/
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

/**setter 方法 － 添加监听*/
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

#pragma mark render回调 －

- (void)setRender:(IBLRender *)render {
    _render = render;
    _render.delegate = self;
}

/**每一次渲染的回调 一个gif 播放完后*/
- (void)renderEachComplete {
    
}

- (void)renderComplite {
    if (self.completeCallback) {
        self.completeCallback();
    }
}

@end
