//
//  VCBaseEncoderConfig.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface VCBaseEncoderConfig : NSObject {
    @protected
    CMVideoCodecType _codecType;
}
@property (nonatomic, readonly) CMVideoCodecType codecType;
@end

