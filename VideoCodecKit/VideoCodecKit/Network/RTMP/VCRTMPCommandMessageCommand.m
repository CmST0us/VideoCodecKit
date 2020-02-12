//
//  VCRTMPCommandMessageCommand.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPCommandMessageCommand.h"
#import "VCAMF0Serialization.h"
#import "VCRTMPMessage.h"

@implementation VCRTMPCommandMessageCommand
- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}
- (NSData *)chunkData {
    return _data;
}
- (void)serializeToByteArray:(VCByteArray *)byteArray {
    [byteArray writeBytes:[self serialize]];
}
- (NSData *)serialize {
    return [NSData data];
}

- (void)deserialize {
    
}
@end

NSString * const VCRTMPCommandMessageResponseSuccess = @"_result";
NSString * const VCRTMPCommandMessageResponseError = @"_error";
NSString * const VCRTMPCommandMessageResponseLevelStatus = @"status";
@implementation VCRTMPCommandMessageResponse
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.response) {
        [serialization serialize:self.response.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}

- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.response = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
}
@end

@implementation VCRTMPChunk (CommandMessageComand)
+ (instancetype)makeNetConnectionCommand:(VCRTMPCommandMessageCommand *)command {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeAMF0Command;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDCommand message:message];
    chunk.chunkData = [command serialize];
    return chunk;
}

+ (instancetype)makeNetStreamCommand:(VCRTMPCommandMessageCommand *)command {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeAMF0Command;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDCommand message:message];
    chunk.chunkData = [command serialize];
    return chunk;
}

- (NSString *)commandTypeValue {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:self.chunkData];
    return [serialization deserialize].value;
}
- (NSNumber *)transactionIDValue {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:self.chunkData];
    [serialization deserialize];
    return [serialization deserialize].value;
}
@end

#pragma mark - Net Connection Command Connect
@implementation VCRTMPNetConnectionCommandConnect
+ (instancetype)command {
    VCRTMPNetConnectionCommandConnect *command = [[VCRTMPNetConnectionCommandConnect alloc] init];
    command.commandName = @"connect";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.commandObject) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.commandObject];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.optionalUserArguments) {
        VCActionScriptObject *opt = [VCActionScriptObject asTypeWithDictionary:self.optionalUserArguments];
        [serialization serialize:opt];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.commandName = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.commandObject = [serialization deserialize].value;
    self.optionalUserArguments = [serialization deserialize].value;
}
@end

@implementation VCRTMPNetConnectionCommandConnectResult
+ (instancetype)command {
    VCRTMPNetConnectionCommandConnectResult *command = [[VCRTMPNetConnectionCommandConnectResult alloc] init];
    command.response = @"_result";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.response) {
        [serialization serialize:self.response.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.properties) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.properties];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.information) {
        VCActionScriptObject *opt = [VCActionScriptObject asTypeWithDictionary:self.information];
        [serialization serialize:opt];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}

- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.response = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.properties = [serialization deserialize].value;
    self.information = [serialization deserialize].value;
}
@end

#pragma mark - Net Connection Command FCPublish
@implementation VCRTMPNetConnectionCommandFCPublish
+ (instancetype)command {
    VCRTMPNetConnectionCommandFCPublish *command = [[VCRTMPNetConnectionCommandFCPublish alloc] init];
    command.commandName = @"FCPublish";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.commandObject) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.commandObject];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.streamName) {
        [serialization serialize:self.streamName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.commandName = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.commandObject = [serialization deserialize].value;
    self.streamName = [serialization deserialize].value;
}
@end

#pragma mark - Net Connection Command Create Stream
@implementation VCRTMPNetConnectionCommandCreateStream
+ (instancetype)command {
    VCRTMPNetConnectionCommandCreateStream *command = [[VCRTMPNetConnectionCommandCreateStream alloc] init];
    command.commandName = @"createStream";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.commandObject) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.commandObject];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.commandName = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.commandObject = [serialization deserialize].value;
}
@end

@implementation VCRTMPNetConnectionCommandCreateStreamResult
+ (instancetype)command {
    VCRTMPNetConnectionCommandCreateStreamResult *command = [[VCRTMPNetConnectionCommandCreateStreamResult alloc] init];
    command.response = @"_result";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.response) {
        [serialization serialize:self.response.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.commandObject) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.commandObject];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.streamID) {
        [serialization serialize:self.streamID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}

- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.response = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.commandObject = [serialization deserialize].value;
    self.streamID = [serialization deserialize].value;
}
@end

#pragma mark - Net Connection Command Release Stream

@implementation VCRTMPNetConnectionCommandReleaseStream
+ (instancetype)command {
    VCRTMPNetConnectionCommandReleaseStream *command = [[VCRTMPNetConnectionCommandReleaseStream alloc] init];
    command.commandName = @"releaseStream";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    [serialization serialize:[NSNull asNull]];
    if (self.streamName) {
        [serialization serialize:self.streamName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.commandName = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.commandObject = [serialization deserialize].value;
    self.streamName = [serialization deserialize].value;
}
@end

#pragma mark - Net Stream Command Publish
NSString * const VCRTMPNetStreamCommandPublishTypeLive = @"live";
NSString * const VCRTMPNetStreamCommandPublishTypeRecord = @"record";
NSString * const VCRTMPNetStreamCommandPublishTypeAppend = @"append";
@implementation VCRTMPNetStreamCommandPublish
+ (instancetype)command {
    VCRTMPNetStreamCommandPublish *command = [[VCRTMPNetStreamCommandPublish alloc] init];
    command.commandName = @"publish";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.commandObject) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.commandObject];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.publishingName) {
        [serialization serialize:self.publishingName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.publishingType) {
        [serialization serialize:self.publishingType.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.commandName = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.commandObject = [serialization deserialize].value;
    self.publishingName = [serialization deserialize].value;
    self.publishingType = [serialization deserialize].value;
}
@end

NSString * const VCRTMPNetStreamCommandOnStatusStart = @"NetStream.Publish.Start";
@implementation VCRTMPNetStreamCommandOnStatus
+ (instancetype)command {
    VCRTMPNetStreamCommandOnStatus *command = [[VCRTMPNetStreamCommandOnStatus alloc] init];
    command.response = @"onStatus";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.response) {
        [serialization serialize:self.response.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.properties) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.properties];
        [serialization serialize:commandObj];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.information) {
        VCActionScriptObject *opt = [VCActionScriptObject asTypeWithDictionary:self.information];
        [serialization serialize:opt];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.response = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
    self.properties = [serialization deserialize].value;
    self.information = [serialization deserialize].value;
}
@end

@implementation VCRTMPNetStreamCommandSetDataFrame
+ (instancetype)command {
    VCRTMPNetStreamCommandSetDataFrame *command = [[VCRTMPNetStreamCommandSetDataFrame alloc] init];
    command.commandName = @"@setDataFrame";
    return command;
}
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.subCommandName) {
        [serialization serialize:self.subCommandName.asString];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    if (self.param) {
        VCActionScriptECMAArray *param = [VCActionScriptECMAArray asTypeWithDictionary:self.param];
        [serialization serialize:param];
    } else {
        [serialization serialize:[NSNull asNull]];
    }
    
    return serialization.serializedData;
}
- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.commandName = [serialization deserialize].value;
    self.subCommandName = [serialization deserialize].value;
    self.param = [serialization deserialize].value;
}
@end
