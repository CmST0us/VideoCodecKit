//
//  VCDemoAMFTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoAMFTestViewController.h"

@implementation VCDemoAMFTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = @{
                           @"tcUrl": @"rtmp://localhost:1935/live".asString,
                           @"flashVer": @"FMLE/3.0 (compatible; FMSc/1.0)".asString,
                           @"swfUrl": NSNull.asNull,
                           @"fpad": @(NO).asBool,
                           @"audioCodecs": @(1024).asNumber
                           };
    VCAMF0Serialization *serialization = [[VCAMF0Serialization alloc] init];
    [serialization serialize:[VCActionScriptObject asTypeWithDictionary:dict]];
    serialization.position = 0;
    VCActionScriptType *type = [serialization deserialize];
    if ([type isKindOfClass:[VCActionScriptObject class]]) {
        VCActionScriptObject *obj = (VCActionScriptObject *)type;
        obj.value;
    }
    
}

@end
