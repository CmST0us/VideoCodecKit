//
//  VCEncoderController.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoCodecKit/VideoCodecKit.h>

@interface VCEncoderController : NSObject<VCBaseEncoderDelegate>
@property (nonatomic, strong) VCVTH264Encoder *encoder;
@property (nonatomic, copy) NSString *outputFile;
- (void)runEncoder;
@end

