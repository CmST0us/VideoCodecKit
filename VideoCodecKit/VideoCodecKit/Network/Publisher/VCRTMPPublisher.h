//
//  VCRTMPPublisher.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/15.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const VCRTMPPublisherErrorDomain;
typedef NS_ENUM(NSUInteger, VCRTMPPublisherErrorCode) {
    VCRTMPPublisherErrorCodeHandshakeFailed = -10,
    VCRTMPPublisherErrorCodeCreateNetConnectionFailed = -11,
    VCRTMPPublisherErrorCodeCreateNetStreamFailed = -12,
    VCRTMPPublisherErrorCodePublishStreamFailed = -13,
    VCRTMPPublisherErrorCodeConnectionFailed = -14,
    VCRTMPPublisherErrorCodeProtocolUnsupport = -15,
    VCRTMPPublisherErrorCodeBadURL = -15,
};

typedef NS_ENUM(NSUInteger, VCRTMPPublisherState) {
    VCRTMPPublisherStateInit,
    VCRTMPPublisherStateReadyToPublish,
    VCRTMPPublisherStateError,
    VCRTMPPublisherStateEnd,
};

@class VCRTMPPublisher;
@protocol VCRTMPPublisherDelegate <NSObject>
- (void)publisher:(VCRTMPPublisher *)publisher didChangeState:(VCRTMPPublisherState)state error:(NSError * _Nullable )error;
@end

@class VCActionScriptType;
@class VCFLVTag;
@interface VCRTMPPublisher : NSObject

@property (nonatomic, readonly) VCRTMPPublisherState state;
@property (nonatomic, weak) id<VCRTMPPublisherDelegate> delegate;

@property (nonatomic, strong) NSDictionary<NSString *, VCActionScriptType *> *connectionParameter;
@property (nonatomic, strong) NSDictionary<NSString *, VCActionScriptType *> *streamMetaData;

- (instancetype)initWithURL:(NSURL *)url
                 publishKey:(NSString *)publishKey;

- (void)start;
- (void)stop;

- (void)writeTag:(VCFLVTag *)tag;

@end

NS_ASSUME_NONNULL_END
