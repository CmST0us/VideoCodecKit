//
//  VCFLVFile.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCFLVFile.h"
#import "VCByteArray.h"
#import "VCFLVTag.h"

#define kVCFLVFileHeaderSize (9)
#define kVCFLVFileFirstTagOffset (13)

@interface VCFLVFile ()
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, assign) NSUInteger fileSize;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, strong) NSData *headerData;
@end

@implementation VCFLVFile
- (instancetype)initWithURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _currentOffset = 0;
        NSError *error;
        _fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
        if (error && ![self isFLVFile]) {
            return nil;
        }
        _fileSize = [_fileHandle seekToEndOfFile];
        [_fileHandle seekToFileOffset:0];
        
        _headerData = [_fileHandle readDataOfLength:kVCFLVFileHeaderSize];
        _currentOffset = kVCFLVFileHeaderSize;
        [_fileHandle seekToFileOffset:kVCFLVFileFirstTagOffset];
        _currentOffset = kVCFLVFileFirstTagOffset;
    }
    return self;
}

- (BOOL)isFLVFile {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.headerData];
    if ('F' == [array readInt8] &&
        'L' == [array readInt8] &&
        'V' == [array readInt8]) {
        return YES;
    }
    return NO;
}

- (uint8_t)version {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.headerData];
    array.postion = 3;
    return [array readUInt8];
}

- (uint32_t)dataOffset {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.headerData];
    array.postion = 5;
    return [array readUInt32];
}

- (VCFLVTag *)nextTag {
    if (_currentOffset == _fileSize) {
        return nil;
    }
    
    [_fileHandle seekToFileOffset:_currentOffset];
    
    VCFLVTag *nextTag = nil;
    
    NSMutableData *tagData = [[NSMutableData alloc] initWithData:[_fileHandle readDataOfLength:kVCFLVTagHeaderSize]];
    if (tagData == nil) {
        return nil;
    }
    
    VCByteArray *array = [[VCByteArray alloc] initWithData:tagData];
    VCFLVTagType type = [array readUInt8];
    uint32_t tagSize = [array readUInt24];
    [tagData appendData:[_fileHandle readDataOfLength:tagSize]];
    
    
    if (type == VCFLVTagTypeVideo) {
        nextTag = [[VCFLVVideoTag alloc] initWithData:tagData];
    } else if (type == VCFLVTagTypeAudio) {
        nextTag = [[VCFLVAudioTag alloc] initWithData:tagData];
    } else if (type == VCFLVTagTypeMeta) {
        nextTag = [[VCFLVMetaTag alloc] initWithData:tagData];
    } else {
        
    }
    
    _currentOffset += tagData.length;
    _currentOffset += 4;
    return nextTag;
}

@end
