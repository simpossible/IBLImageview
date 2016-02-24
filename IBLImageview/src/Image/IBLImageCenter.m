//
//  IBLImageCenter.m
//  testgif
//
//  Created by simpossible on 16/1/31.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#import "IBLImageCenter.h"
#import <CommonCrypto/CommonDigest.h>
#import "IBLImage.h"
#import <Foundation/Foundation.h>
@interface IBLImageCenter ()

@property(nonatomic, strong)NSMutableDictionary *iblMd5Images;

@property(nonatomic, strong)NSMutableDictionary *iblKeyImages;
@end

@implementation IBLImageCenter

+(IBLImageCenter *)sharedCenter{
    static dispatch_once_t token;
    static IBLImageCenter* sharedCenter = nil;
    
    dispatch_once(&token, ^{
        sharedCenter = [[IBLImageCenter alloc]init];
    });
    return sharedCenter;
}

- (instancetype)init{
    if (self = [super init]) {
        _iblMd5Images = [NSMutableDictionary dictionary];
    }
    return  self;
}

- (IBLImage*)getIBLImageWithPath:(NSString*)path{
    CFStringRef md5 = FileMD5HashCreateWithPath((__bridge CFStringRef)(path));
    NSString *gifMd5 = (__bridge_transfer NSString*)md5;
    
    IBLImage *image = [_iblMd5Images objectForKey:gifMd5];
    
    if (!image) {
        image = [[IBLImage alloc]initWithPath:path];
        [_iblMd5Images setObject:image forKey:gifMd5];
    }
        
    return image;
}

- (IBLImage *)getIBLImageWithKey:(NSString *)imageKey{
    IBLImage *image = nil;
    if (!imageKey && ![imageKey isEqualToString:@""]) {
        image = [_iblKeyImages objectForKey:imageKey];
    }
    return image;
}

- (IBLImage *)getIBLImageWithKey:(NSString *)imageKey andImageArray:(NSArray *)images andDelays:(NSArray *)array{
    IBLImage *iblImage;
    
    if (imageKey) {
        iblImage = nil;
    }else{
        iblImage = _iblKeyImages[imageKey];
        if (!iblImage) {
            iblImage = [[IBLImage alloc]initWithImagesArray:images andClamTimesArray:array];
        }
    }
    return iblImage;
}

/**获取MD5值*/
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[4096];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    
    NSLog(@"MD5// %@",result);
    
    return result;
}

@end
