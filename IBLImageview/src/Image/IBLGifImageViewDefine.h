//
//  IBLGifImageViewDefine.h
//  IBLImageview
//
//  Created by simpossible on 16/3/18.
//  Copyright © 2016年 simpossible. All rights reserved.
//

#ifndef IBLGifImageViewDefine_h
#define IBLGifImageViewDefine_h

typedef NS_ENUM(NSInteger,IBLImageType) {
    IBLImageTypeRenderAllTheTime,///< 一只渲染 与视图的关系为 1 － 多
    IBLImageTypeRenderWithTImes,///<只渲染固定次数 与视图的关系为 1 － 1
};

#define kIBL_IMG_RE_ANIMATE @"iblimageviewtoreanimation"


#endif /* IBLGifImageViewDefine_h */
