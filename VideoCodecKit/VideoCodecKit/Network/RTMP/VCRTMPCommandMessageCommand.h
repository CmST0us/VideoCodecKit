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
- (instancetype)initWithData:(NSData *)data;
- (void)serializeToByteArray:(VCByteArray *)byteArray;
- (NSData *)serialize;
- (void)deserialize;
@end

@interface VCRTMPCommandMessageCommandFactory : NSObject
+ (nullable VCRTMPCommandMessageCommand *)commandWithType:(NSString *)type
                                                     data:(NSData *)data;
@end

@class VCRTMPCommandMessageCommand;
@interface VCRTMPChunk (CommandMessageComand)
+ (instancetype)makeNetConnectionCommand:(VCRTMPCommandMessageCommand *)command;
- (NSString *)commandTypeValue;
@end

@interface VCRTMPNetConnectionCommandConnect : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *commandObject;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *optionalUserArguments;
@end

@interface VCRTMPNetConnectionCommandConnectResult : VCRTMPCommandMessageCommand
@property (nonatomic, copy, nullable) NSString *commandName;
@property (nonatomic, strong, nullable) NSNumber *transactionID;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *properties;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, VCActionScriptType *> *information;
@end

NS_ASSUME_NONNULL_END
