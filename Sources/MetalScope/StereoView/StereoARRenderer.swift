//
//  StereoARRenderer.swift
//
//
//  Created by Mathijs Bernson on 18/06/2024.
//

import Metal
import ARKit

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

internal final class StereoARRenderer {
    let session: ARSession
    let device: MTLDevice
    var renderDestination: RenderDestinationProvider

    let textureCache: CVMetalTextureCache

    // Metal objects
    var pipelineState: MTLRenderPipelineState
    var commandQueue: MTLCommandQueue
    var currentFrameTexture: MTLTexture?

    private let renderSemaphore = DispatchSemaphore(value: 6)
    private let eyeRenderingConfigurations: [Eye: EyeRenderingConfiguration]

    // The current viewport size
    var viewportSize: CGSize = CGSize()

    // Flag for viewport size changes
    var viewportSizeDidChange: Bool = false

    init(session: ARSession, metalDevice device: MTLDevice, renderDestination: RenderDestinationProvider) throws {
        self.session = session
        self.device = device
        self.renderDestination = renderDestination

        guard let commandQueue = device.makeCommandQueue() else {
            throw CVError(code: 42)
        }
        self.commandQueue = commandQueue

        var cacheOutput: CVMetalTextureCache?
        let code = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cacheOutput)

        guard let cache = cacheOutput else {
            throw CVError(code: code)
        }

        self.textureCache = cache

        // Load and compile the shaders
        let defaultLibrary = device.makeDefaultLibrary()
        guard let vertexFunction = defaultLibrary?.makeFunction(name: "ar_vertex_main") else {
            print("Missing vertex function")
            throw CVError(code: 42)
        }
        guard let fragmentFunction = defaultLibrary?.makeFunction(name: "ar_fragment_main") else {
            print("Missing fragment function")
            throw CVError(code: 42)
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = renderDestination.colorPixelFormat

        pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        // TODO: Finish this
        eyeRenderingConfigurations = [:]
//        eyeRenderingConfigurations = [
//            .left: .init(texture: any MTLTexture),
//            .right: .init(texture: any MTLTexture),
//        ]
    }

    func drawRectResized(size: CGSize) {
        viewportSize = size
        viewportSizeDidChange = true
    }

    func update() {
        if let pixelBuffer = session.currentFrame?.capturedImage {
            currentFrameTexture = texture(from: pixelBuffer)
            draw()
        }
    }

    private func draw() {
        guard let currentDrawable = renderDestination.currentDrawable,
              let renderPassDescriptor = renderDestination.currentRenderPassDescriptor else {
            return
        }

        // Create a command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()

        // Create a render command encoder
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)

        // Set the texture to the render encoder
        if let texture = currentFrameTexture {
            renderEncoder?.setFragmentTexture(texture, index: 0)
        }

        // Draw a quad (assuming vertex buffer and other setup is done)
        // renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        // Finalize rendering
        renderEncoder?.endEncoding()
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
    }

    private func texture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        var cvMetalTexture: CVMetalTexture?
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let pixelFormat = MTLPixelFormat.bgra8Unorm

        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, pixelFormat, width, height, 0, &cvMetalTexture)

        guard result == kCVReturnSuccess, let metalTexture = cvMetalTexture else {
            return nil
        }

        return CVMetalTextureGetTexture(metalTexture)
    }
}
