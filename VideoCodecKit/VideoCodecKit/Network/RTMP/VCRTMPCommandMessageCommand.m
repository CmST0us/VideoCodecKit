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

@implementation VCRTMPCommandMessageCommandFactory

+ (NSDictionary<NSString *, Class> *)commandClassMap {
    static NSDictionary *map = nil;
    if (map != nil) {
        return map;
    }
    map = @{
        @"_result": [VCRTMPNetConnectionCommandConnectResult class],
        @"connect": [VCRTMPNetConnectionCommandConnect class]
    };
    return map;
}

+ (VCRTMPCommandMessageCommand *)commandWithType:(NSString *)type data:(NSData *)data {
    Class classType = [self commandClassMap][type];
    if (classType == nil ||
        ![classType isSubclassOfClass:[VCRTMPCommandMessageCommand class]]) {
        return nil;
    }
    VCRTMPCommandMessageCommand *command = [[classType alloc] initWithData:data];
    [command deserialize];
    return command;
}

@end

NSString * const VCRTMPCommandMessageResponseSuccess = @"_result";
NSString * const VCRTMPCommandMessageResponseError = @"_error";
@implementation VCRTMPCommandMessageResponse
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.response) {
        [serialization serialize:self.response.asString];
    }
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    } 
    return serialization.serializedData;
}

- (void)deserialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] initWithData:_data];
    self.response = [serialization deserialize].value;
    self.transactionID = [serialization deserialize].value;
}
@end
@implementation VCRTMPCommandMessageTask
@end

@implementation VCRTMPChunk (CommandMessageComand)
+ (instancetype)makeNetConnectionCommand:(VCRTMPCommandMessageCommand *)command {
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
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.commandName) {
        [serialization serialize:self.commandName.asString];
    }
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    }
    if (self.commandObject) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.commandObject];
        [serialization serialize:commandObj];
    }
    if (self.optionalUserArguments) {
        VCActionScriptObject *opt = [VCActionScriptObject asTypeWithDictionary:self.optionalUserArguments];
        [serialization serialize:opt];
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
- (NSData *)serialize {
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    if (self.response) {
        [serialization serialize:self.response.asString];
    }
    if (self.transactionID) {
        [serialization serialize:self.transactionID.asNumber];
    }
    if (self.properties) {
        VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:self.properties];
        [serialization serialize:commandObj];
    }
    if (self.information) {
        VCActionScriptObject *opt = [VCActionScriptObject asTypeWithDictionary:self.information];
        [serialization serialize:opt];
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

