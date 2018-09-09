//
//  VCBaseFrameParser.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCFrameTypeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class VCBaseFrameParser;
@protocol VCFrameParserDataSource<NSObject>
- (NSData *)feedDataForFrameParser:(VCBaseFrameParser *)frameParser;
@end

@protocol VCFrameParserDelegate<NSObject>
- (void)frameParserDidParseFrame:(id<VCFrameTypeProtocol>)aFrame;
@end

@interface VCBaseFrameParser : NSObject

@property (nonatomic, weak) id<VCFrameParserDataSource> dataSource;
@property (nonatomic, weak) id<VCFrameParserDelegate> delegate;

@property (nonatomic, assign) NSUInteger pasrseCount;

- (NSInteger)parseData:(void *)buffer
                length:(NSUInteger)length;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
