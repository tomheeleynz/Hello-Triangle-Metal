//
//  Shaders.metal
//  MetalTriangle
//
//  Created by Thomas Heeley on 10/07/21.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn vertexIn[[stage_in]]) {
    VertexOut out;
    out.position = float4(vertexIn.position, 1.0);
    out.color = float4(vertexIn.color, 1.0);
    return out;
};

fragment float4 fragment_main(const VertexOut in [[stage_in]]) {
    return in.color;
};
