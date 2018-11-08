//
//  VCMetalRender.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCMetalRender.h"
#import "VCYUV420PImage.h"
#import "VCMetalShaderType.h"
#import "VCSafeObjectQueue.h"

// 如果外部sampleBuffer有重用，则必须为1
#define kVCMetalRenderImageQueueSize 1

#if (TARGET_IPHONE_SIMULATOR)
#else

@interface VCMetalRender ()<MTKViewDelegate>
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> converMatrix;
@property (nonatomic, strong) id<MTLBuffer> vertics;
@property (nonatomic, assign) NSInteger numberOfVertics;
@property (nonatomic, strong) VCBaseImage *renderImage;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

@end

@implementation VCMetalRender
- (instancetype)init {
    self = [super init];
    if (self) {
        self.mtkView = [[MTKView alloc] init];
        self.mtkView.device = MTLCreateSystemDefaultDevice();;
        self.mtkView.delegate = self;
        self.viewportSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
        CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, self.mtkView.device, NULL, &_textureCache);
        
        [self setupPipeline];
        [self setupVertex];
        [self setupMatrix];        
    }
    return self;
}

- (void)dealloc {
    if (_textureCache != NULL) {
        CFRelease(_textureCache);
        _textureCache = NULL;
    }
}

#pragma mark - Metal Setup
// 设置渲染管道
-(void)setupPipeline {
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newLibraryWithFile:[[NSBundle videoCodecKitBundle] pathForResource:@"default" ofType:@"metallib"] error:nil];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"]; // 顶点shader，vertexShader是函数名
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"]; // 片元shader，samplingShader是函数名
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                             error:NULL]; // 创建图形渲染管道，耗性能操作不宜频繁调用
    self.commandQueue = [self.mtkView.device newCommandQueue]; // CommandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
}

// 设置顶点数据
- (void)setupVertex {
    static const VCMetalVertex quadVertics[] = {
        // 左下角三角形
        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 1.f } },
        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
        // 右上角三角形
        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  1.0,  1.0, 0.0, 1.0 },  { 1.f, 0.f } },
    };
    self.vertics = [self.mtkView.device newBufferWithBytes:quadVertics length:sizeof(quadVertics) options:MTLResourceStorageModeShared];
    self.numberOfVertics = sizeof(quadVertics) / sizeof(VCMetalVertex);
}

// 设置转换矩阵
- (void)setupMatrix {
    matrix_float3x3 kVCMetalColorConversion601FullRangeMatrix = (matrix_float3x3) {
        (simd_float3){1.0,    1.0,    1.0},
        (simd_float3){0.0,    -0.343, 1.765},
        (simd_float3){1.4,    -0.711, 0.0},
    };
    vector_float3 kVCMetalColorConversion601FullRangeOffset = (vector_float3) {
        -(16.0 / 255.0), -0.5, -0.5
    };
    VCMetalConverMatrix converMatrix;
    converMatrix.matrix = kVCMetalColorConversion601FullRangeMatrix;
    converMatrix.offset = kVCMetalColorConversion601FullRangeOffset;
    self.converMatrix = [self.mtkView.device newBufferWithBytes:&converMatrix length:sizeof(VCMetalConverMatrix) options:MTLResourceStorageModeShared];
}

- (BOOL)setupTextureWithEncoder:(id<MTLRenderCommandEncoder>)encoder
                          image:(VCYUV420PImage *)image {
    // [TODO] 直接用 YUV 裸数据生成贴图
    id<MTLTexture> textureY = nil;
    id<MTLTexture> textureUV = nil;
    CVPixelBufferRef pixelBuffer = image.pixelBuffer;
    {
        // textureY
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        MTLPixelFormat pixelFormat = MTLPixelFormatR8Unorm;
        CVMetalTextureRef texture = NULL;
        CVReturn ret = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, pixelFormat, width, height, 0, &texture);
        if (ret == kCVReturnSuccess) {
            textureY = CVMetalTextureGetTexture(texture);
            CFRelease(texture);
        } else {
            return NO;
        }
    }
    
    {
        // textureUV
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        MTLPixelFormat pixelFormat = MTLPixelFormatRG8Unorm;
        CVMetalTextureRef texture = NULL;
        CVReturn ret = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, pixelFormat, width, height, 1, &texture);
        if (ret == kCVReturnSuccess) {
            textureUV = CVMetalTextureGetTexture(texture);
            CFRelease(texture);
        } else {
            return NO;
        }
    }
    
    if (textureY != nil && textureUV != nil) {
        [encoder setFragmentTexture:textureY atIndex:0];
        [encoder setFragmentTexture:textureUV atIndex:1];
    }
    return YES;
}
#pragma mark - Delegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewportSize = (vector_uint2){
        size.width,
        size.height
    };
}
- (void)drawInMTKView:(MTKView *)view {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescription = view.currentRenderPassDescriptor;
    VCYUV420PImage *image = (VCYUV420PImage *)self.renderImage;
    if (renderPassDescription == nil
        || image == nil
        || [image isKindOfClass:[VCYUV420PImage class]] == NO) {
        // commit 会算入帧率
        [commandBuffer commit];
        return;
    };
    renderPassDescription.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0f);
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescription];
    [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0}];
    [renderEncoder setRenderPipelineState:self.pipelineState]; // 设置渲染管道
    [renderEncoder setVertexBuffer:self.vertics offset:0 atIndex:0];
    // texture
    if (![self setupTextureWithEncoder:renderEncoder image:image]) {
        [renderEncoder endEncoding];
        [commandBuffer commit];
        return;
    }
    [renderEncoder setFragmentBuffer:self.converMatrix offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numberOfVertics]; // 绘制三角形
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

#pragma mark - Override
- (void)attachToView:(UIView *)view {
    if (self.mtkView && view) {
        [self.mtkView removeFromSuperview];
        [view addSubview:self.mtkView];
    }
}

- (UIView *)renderView {
    return self.mtkView;
}

- (void)render:(id)image {
    if (image != nil) {
        // 断言渲染速度比喂数据快，如果渲染慢也没必要把时间消耗在过期的帧上了，直接显示最新的就行了
        self.renderImage = image;
    }
}

- (NSArray<NSString *> *)supportRenderClassName {
    return @[
             NSStringFromClass([VCYUV420PImage class]),
             ];
}
@end

#endif
