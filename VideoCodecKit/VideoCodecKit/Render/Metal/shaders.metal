//
//  shaders.metal
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#include <metal_stdlib>
#include "VCMetalShaderType.h"

using namespace metal;
typedef struct
{
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    
    float2 textureCoordinate; // 纹理坐标，会做插值处理
    
} RasterizerData;

vertex RasterizerData // 返回给片元着色器的结构体
vertexShader(uint vertexID [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant VCMetalVertex *vertexArray [[ buffer(0) ]]) { // buffer表明是缓存数据，0是索引
    RasterizerData out;
    out.clipSpacePosition = vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
}

fragment float4
samplingShader(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<float> textureY [[ texture(0) ]], // texture表明是纹理数据，LYFragmentTextureIndexTextureY是索引
               texture2d<float> textureUV [[ texture(1) ]], // texture表明是纹理数据，LYFragmentTextureIndexTextureUV是索引
               constant VCMetalConverMatrix *convertMatrix [[ buffer(0) ]]) //buffer表明是缓存数据，LYFragmentInputIndexMatrix是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
    float3 yuv = float3(textureY.sample(textureSampler, input.textureCoordinate).r,
                        textureUV.sample(textureSampler, input.textureCoordinate).rg);
    
    float3 rgb = convertMatrix->matrix * (yuv + convertMatrix->offset);
    
    return float4(rgb, 1.0);
}
