//
//  VCMarco.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#ifndef VCMarco_h
#define VCMarco_h

#pragma mark - State Machine Tools
#define kVCAllowState(allow, current) [allow containsObject:current]

#pragma mark - String Tools
#define DECLARE_CONST_STRING(str) extern NSString const * str
#define CONST_STRING(str) NSString * str = @#str

#pragma mark - Value Define
#define kVCRTMPPort (1935)

#define kVC720P (1280 * 720)
#define kVC1080P (1920 * 1080)
#define kVC480P (720 * 480)

#define kVCPriorityIDR (0)
#define kVCDefaultFPS (30)

#endif /* VCMarco_h */
