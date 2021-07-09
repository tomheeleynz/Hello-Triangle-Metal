//
//  Renderer.swift
//  MetalTriangle
//
//  Created by Thomas Heeley on 10/07/21.
//

import Foundation
import MetalKit
import simd

struct Vertex
{
    var position : SIMD3<Float>
    var color : SIMD3<Float>
}

class Renderer : NSObject
{
    static var device : MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var vertexBuffer : MTLBuffer!
    var pipelineState : MTLRenderPipelineState!
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        metalView.delegate = self
        
        // Create Vertex Descriptor
        let vertexDesciptor = MTLVertexDescriptor()
        
        // -- Position
        vertexDesciptor.attributes[0].format = .float3
        vertexDesciptor.attributes[0].offset = 0
        vertexDesciptor.attributes[0].bufferIndex = 0
        
        // -- Color
        vertexDesciptor.attributes[1].format = .float3
        vertexDesciptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDesciptor.attributes[1].bufferIndex = 0
        
        // Stride
        vertexDesciptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride * 2
        
        // Set up shader library
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        // Describe Pipeline and Create Pipeline State
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDesciptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        var vertices : [Vertex] = [
            Vertex(position: SIMD3<Float>(0.5, -0.5, 0.0), color: SIMD3<Float>(1.0, 0.5, 0.2)),
            Vertex(position: SIMD3<Float>(-0.5, -0.5, 0.0), color: SIMD3<Float>(1.0, 0.5, 0.2)),
            Vertex(position: SIMD3<Float>(0.0,  0.5, 0.0), color: SIMD3<Float>(1.0, 0.5, 0.2))
        ];
        
        // Create Vertex Buffer and fill
        vertexBuffer = device.makeBuffer(length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
        let bufferPoints = vertexBuffer.contents().bindMemory(to: Vertex.self, capacity: vertices.count)
        bufferPoints.assign(from: &vertices, count: vertices.count)
        
    }
}

extension Renderer : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor else {
            fatalError("No Render Pass Descriptor")
        }
        
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer() else {
            fatalError("Command Buffer Not Created")
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Render encoder not created")
        }
        
        // Drawing Code goes here
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
