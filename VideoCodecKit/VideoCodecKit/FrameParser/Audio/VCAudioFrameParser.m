//
//  VCAudioFrameParser.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//


#import "VCAudioFrameParser.h"
#import "VCAudioFrame.h"
#import "VCAudioFrameParser+AudioFileStreamPropertyParser.h"

@interface VCAudioFrameParser () {
    
}
@property (nonatomic, assign) AudioFileStreamID fileStreamID;
@property (nonatomic, strong) NSMutableDictionary *audioProperty;
@end

@implementation VCAudioFrameParser

#pragma mark - AudioFileStream Callback;
void propertyListenerProc(void *                        inClientData,
                          AudioFileStreamID             inAudioFileStream,
                          AudioFileStreamPropertyID     inPropertyID,
                          AudioFileStreamPropertyFlags *ioFlags) {
    VCAudioFrameParser *parser = (__bridge VCAudioFrameParser *)inClientData;
    [VCAudioFrameParser getAudioFileStreamProperty:inPropertyID
                                          streamID:inAudioFileStream
                                   addToDictionary:parser.audioProperty];
}

void packetsProc(void *                        inClientData,
                 UInt32                        inNumberBytes,
                 UInt32                        inNumberPackets,
                 const void *                  inInputData,
                 AudioStreamPacketDescription *inPacketDescriptions) {
    if (inNumberBytes == 0 || inNumberPackets == 0) {
        return;
    }
    VCAudioFrameParser *parser = (__bridge VCAudioFrameParser *)inClientData;
    
    if (inPacketDescriptions == NULL) {
#if DEBUG
        NSLog(@"[PARSER][AUDIO]: no packet description");
#endif
        UInt32 packetSize = inNumberBytes / inNumberPackets;
        for (int i = 0; i < inNumberPackets; ++i) {
            VCAudioFrame *frame = [[VCAudioFrame alloc] init];
            [frame createParseDataWithSize:packetSize];
            memcpy(frame.parseData, inInputData + packetSize * (i + 1), packetSize);
            [frame.userInfo addEntriesFromDictionary:parser.audioProperty];
            if (parser.delegate && [parser respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                [parser.delegate frameParserDidParseFrame:frame];
            }
        }
    } else {
        for (int i = 0; i < inNumberPackets; ++i) {
            SInt64 packetStart = inPacketDescriptions[i].mStartOffset;
            UInt32 packetSize = inPacketDescriptions[i].mDataByteSize;
            VCAudioFrame *frame = [[VCAudioFrame alloc] init];
            [frame createParseDataWithSize:packetSize];
            memcpy(frame.parseData, inInputData + packetStart, packetSize);
            [frame.userInfo addEntriesFromDictionary:parser.audioProperty];
            if (parser.delegate && [parser.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                [parser.delegate frameParserDidParseFrame:frame];
            }
        }
    }
    
    
}

- (instancetype)initWithAudioType:(AudioFileTypeID)audioType {
    self = [super init];
    if (self) {
        _audioType = audioType;
        _audioProperty = [NSMutableDictionary dictionary];
        [self initAudioFileStream];
    }
    return self;
}

- (instancetype)init {
    return [self initWithAudioType:kAudioFileAAC_ADTSType];
}

#pragma mark - Private Method
- (void)initAudioFileStream {
    OSStatus ret;
    ret = AudioFileStreamOpen((__bridge void * _Nullable)(self), propertyListenerProc, packetsProc, self.audioType, &_fileStreamID);
    if (ret != noErr) {
        NSLog(@"[PARSER][AUDIO]: audio file stream open err");
        return;
    }
}

#pragma mark - Override Method
- (NSInteger)parseData:(void *)buffer length:(NSInteger)length {
    if (_fileStreamID == nil) {
        return -1;
    }
    // [TODO]: Support Discontinuity
    OSStatus ret = AudioFileStreamParseBytes(_fileStreamID, (UInt32)length, buffer, 0);
    if (ret != noErr) return -1;
    return 0;
}

- (void)reset {
    if (_fileStreamID != nil) {
        AudioFileStreamClose(_fileStreamID);
        _fileStreamID = NULL;
    }
    [_audioProperty removeAllObjects];
    [self initAudioFileStream];
}

@end
