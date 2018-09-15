//
//  VCYUV422Image.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCYUV422Image : NSObject

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, assign) NSUInteger bytesPerRow;

@property (nonatomic, assign) uint8_t *luma; //Y
@property (nonatomic, assign) NSUInteger lumaSize;
@property (nonatomic, assign) uint8_t *chromaB; // U
@property (nonatomic, assign) NSUInteger chromaBSize;
@property (nonatomic, assign) uint8_t *chromaR; // V
@property (nonatomic, assign) NSUInteger chromaRSize;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                  bytesPerRow:(NSUInteger)bytesPerRow;

@end
