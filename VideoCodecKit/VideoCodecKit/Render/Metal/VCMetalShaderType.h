//
//  VCMetalShaderType.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#ifndef VCMetalShaderType_h
#define VCMetalShaderType_h

#include <simd/simd.h>

typedef struct {
    vector_float4 position; // 顶点坐标, (x, y, z, w)
    vector_float2 textureCoordinate; // 贴图坐标 (x, y)
} VCMetalVertex;

typedef struct {
    matrix_float3x3 matrix;
    vector_float3 offset;
} VCMetalConverMatrix;
#endif /* VCMetalShaderType_h */
