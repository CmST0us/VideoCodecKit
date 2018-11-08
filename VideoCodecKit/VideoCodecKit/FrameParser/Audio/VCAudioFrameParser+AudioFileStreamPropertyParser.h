//
//  VCAudioFrameParser+AudioFileStreamPropertyParser.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>

@interface VCAudioFrameParser (AudioFileStreamPropertyParser)
+ (void)getAudioFileStreamProperty:(AudioFilePropertyID)propertyID
                          streamID:(AudioFileStreamID)streamID
                   addToDictionary:(NSMutableDictionary *)dict;
@end
