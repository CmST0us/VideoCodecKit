//
//  VCAutoResizeLayerView.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCAutoResizeLayerView : UIView
- (void)addAutoResizeSubLayer:(CALayer *)layer;
- (void)removeAutoResizeSubLayer:(CALayer *)layer;
@end

NS_ASSUME_NONNULL_END
