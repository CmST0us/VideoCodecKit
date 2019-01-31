//
//  VCDemoISOTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/1/27.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCDemoISOTestViewController.h"
#import <VideoCodecKit/VideoCodecKit.h>

@interface VCDemoISOTestViewController () <VCFLVReaderDelegate, VCVideoDecoderDelegate> {
    dispatch_queue_t _decodeWorkQueue;
}
@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@end

@implementation VCDemoISOTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _decodeWorkQueue = dispatch_queue_create("com.vc.decode", DISPATCH_QUEUE_SERIAL);
    self.decoder = [[VCH264HardwareDecoder alloc] init];
    self.decoder.delegate = self;
    self.displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    self.displayLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.displayLayer];
    
//    uint8_t d[] = {
//        0x00, 0x00, 0x00, 0x01, 0x00, 0x23, 0x00, 0x00, 0x01, 0x65, 0x00, 0x00, 0x00, 0x01, 0x67, 0x00, 0x03
//    };
//    NSData *data = [[NSData alloc] initWithBytes:d length:sizeof(d)];
//    VCAnnexBFormatStream *s = [[VCAnnexBFormatStream alloc] initWithData:data];
//    VCAVCFormatStream *avc = [s toAVCFormatStream];
//
//    VCAnnexBFormatParser *parser = [[VCAnnexBFormatParser alloc] init];
//    [parser appendData:data];
//
//    VCAnnexBFormatStream *nextStream = nil;
//    while ((nextStream = [parser next]) != nil) {
//        VCAVCFormatStream *avcS = [nextStream toAVCFormatStream];
//    }
    
    // File Test
//    NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:@"/Users/cmst0us/Desktop/swift.h264"];
//    [readStream open];
//
//    while ([readStream hasBytesAvailable]) {
//        uint8_t readBuffer[4096] = {0};
//        NSInteger readLen = [readStream read:readBuffer maxLength:4096];
//
//        [parser appendData:[NSData dataWithBytes:readBuffer length:readLen]];
//        VCAnnexBFormatStream *next = nil;
//        do {
//            next = [parser next];
//            VCAVCFormatStream *avc = [next toAVCFormatStream];
//
//        } while (next != nil);
//
//    }
    
    VCFLVReader *reader = [[VCFLVReader alloc] initWithURL:[NSURL fileURLWithPath:@"/Users/cmst0us/Desktop/test.flv"]];
    reader.delegate = self;
    [reader starAsyncRead];
    
}

- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    NSLog(@"did get video sample buffer");
    
    OSStatus ret = [self.decoder decodeSampleBuffer:sampleBuffer];
    if (ret == noErr) {
        
    }
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"did get sps pps");
    [self.decoder setFormatDescription:formatDescription];
}

- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    NSLog(@"get output image");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
    });
}

@end
