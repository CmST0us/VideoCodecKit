//
//  VCFLVTag.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVCFLVTagHeaderSize (11)
#define kVCFLVVideoTagExternHeaderSize (5)
#define kVCFLVAudioTagExternHeaderSize (2)
#define kVCFLVMetaTagExternHeaderSize (0)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, VCFLVTagType) {
    VCFLVTagTypeAudio = 8,
    VCFLVTagTypeVideo = 9,
    VCFLVTagTypeMeta = 18,
    VCFLVTagReserve = 0,
};

@interface VCFLVTag : NSObject
@property (nonatomic, readonly) NSData *tagData;

@property (nonatomic, readonly) VCFLVTagType tagType;
@property (nonatomic, readonly) uint32_t dataSize;
@property (nonatomic, readonly) uint32_t timestamp;
@property (nonatomic, readonly) uint8_t timestampExtended;
@property (nonatomic, readonly) uint32_t streamID;
@property (nonatomic, readonly) NSData *payloadData;

- (nullable instancetype)initWithData:(NSData *)data;

@end

typedef NS_ENUM(uint8_t, VCFLVVideoTagFrameType) {
    VCFLVVideoTagFrameTypeKeyFrame = 1,
    VCFLVVideoTagFrameTypeInterFrame = 2,
    VCFLVVideoTagFrameTypeDisposableInterFrame = 3,
    VCFLVVideoTagFrameTypeGeneratedKeyFrame = 4,
    VCFLVVideoTagFrameTypeVideoInfoFrame = 5,
};

typedef NS_ENUM(uint8_t, VCFLVVideoTagEncodeID) {
    VCFLVVideoTagEncodeIDJPEG = 1,
    VCFLVVideoTagEncodeIDH263 = 2,
    VCFLVVideoTagEncodeIDScreenVideo = 3,
    VCFLVVideoTagEncodeIDOn2VP6 = 4,
    VCFLVVideoTagEncodeIDOn2VP6WithAlpha = 5,
    VCFLVVideoTagEncodeIDScreenVideoVersion2 = 6,
    VCFLVVideoTagEncodeIDAVC = 7,
};

typedef NS_ENUM(uint8_t, VCFLVVideoTagAVCPacketType) {
    VCFLVVideoTagAVCPacketTypeSequenceHeader = 0,
    VCFLVVideoTagAVCPacketTypeNALU = 1,
    VCFLVVideoTagAVCPacketTypeEndOfSequence = 2,
};

@interface VCFLVVideoTag : VCFLVTag
@property (nonatomic, readonly) VCFLVVideoTagFrameType frameType;
@property (nonatomic, readonly) VCFLVVideoTagEncodeID encodeID;
@property (nonatomic, readonly) VCFLVVideoTagAVCPacketType AVCPacketType;
@property (nonatomic, readonly) uint32_t compositionTime;
- (BOOL)isSupportCurrentFrameType;
@end

@interface VCFLVAudioTag : VCFLVTag

@end

@interface VCFLVMetaTag : VCFLVTag

@end
NS_ASSUME_NONNULL_END
