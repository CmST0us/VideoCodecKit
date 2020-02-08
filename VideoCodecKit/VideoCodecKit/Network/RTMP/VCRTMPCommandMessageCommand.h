//
//  VCRTMPCommandMessageCommand.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRTMPChunk.h"
#import "VCByteArray.h"
#import "VCActionScriptTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCRTMPCommandMessageCommand : NSObject {
@protected
    NSData *_data;
}
+ (instancetype)command;
- (instancetype)initWithData:(NSData *)data;
- (NSData *)chunkData;
- (void)serializeToByteArray:(VCByteArray *)byteArray;
- (NSData *)serialize;
- (void)deserialize;
@end

@interface VCRTMPCommandMessageCommandFactory : NSObject
+ (nullable VCRTMPCommandMessageCommand *)commandWithType:(NSString *)type
                                                     data:(NSData *)data;
@end

@class VCRTMPCommandMessageResponse;
typedef void(^VCRTMPCommandMessageResponseBlock)(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess);
@interface VCRTMPCommandMessageTask : NSObject
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) SEL handler;
@property (nonatomic, assign) NSUInteger transactionID;
@end

@class VCRTMPCommandMessageCommand;
@interface VCRTMPChunk (CommandMessageComand)
+ (instancetype)makeNetConnectionCommand:(VCRTMPCommandMessageCommand *)command;
+ (instancetype)makeNetStreamCommand:(VCRTMPCommandMessageCommand *)command;
- (NSString *)commandTypeValue;
- (NSNumber *)transactionIDValue;
@end

extern NSString * const VCRTMPCommandMessageResponseSuccess;
extern NSString * const VCRTMPCommandMessageResponseError;
@interface VCRTMPCommandMessageResponse : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *response;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@end

#pragma mark - Net Connection Command

@interface VCRTMPNetConnectionCommandConnect : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *commandObject;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *optionalUserArguments;
@end

@interface VCRTMPNetConnectionCommandConnectResult : VCRTMPCommandMessageResponse
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *properties;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *information;
@end

@interface VCRTMPNetConnectionCommandFCPublish : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptObject *> *commandObject;
@property (nonatomic, strong, nullable) NSString *streamName;
@end

@interface VCRTMPNetConnectionCommandCreateStream : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptObject *> *commandObject;
@end

@interface VCRTMPNetConnectionCommandCreateStreamResult : VCRTMPCommandMessageResponse
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *commandObject;
@property (nonatomic, strong, nullable) NSNumber *streamID;
@end

@interface VCRTMPNetConnectionCommandReleaseStream : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *commandObject;
@property (nonatomic, copy, nullable) NSString *streamName;
@end

#pragma mark - Net Stream Command
extern NSString * const VCRTMPNetStreamCommandPublishTypeLive;
extern NSString * const VCRTMPNetStreamCommandPublishTypeRecord;
extern NSString * const VCRTMPNetStreamCommandPublishTypeAppend;
@interface VCRTMPNetStreamCommandPublish : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *commandObject;
@property (nonatomic, copy, nullable) NSString *publishingName;
@property (nonatomic, copy, nullable) NSString *publishingType;
@end

NS_ASSUME_NONNULL_END
