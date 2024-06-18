//
//  StereoPanorama.swift
//  MetalScope
//
//  Created by Mathijs Bernson on 30/04/2024.
//

import Foundation
import SwiftUI
import SceneKit
import AVFoundation

@available(iOS 13.0, *)
public struct StereoPanorama: UIViewRepresentable {
    let source: PanoramaSource
    let format: MediaFormat
    let stereoParameters: StereoParameters
    let technique: SCNTechnique?

    public init(
        image: UIImage,
        format: MediaFormat = .mono,
        parameters: StereoParameters = StereoParameters(),
        technique: SCNTechnique? = nil
    ) {
        self.source = .image(image)
        self.format = format
        self.stereoParameters = parameters
        self.technique = technique
    }

    public init(
        player: AVPlayer,
        format: MediaFormat = .mono,
        parameters: StereoParameters = StereoParameters(),
        technique: SCNTechnique? = nil
    ) {
        self.source = .video(player)
        self.format = format
        self.stereoParameters = parameters
        self.technique = technique
    }

    public init(
        scene: SCNScene,
        parameters: StereoParameters = StereoParameters(),
        technique: SCNTechnique? = nil
    ) {
        self.source = .scene(scene)
        self.format = .mono // Unused in this case
        self.stereoParameters = parameters
        self.technique = technique
    }

    public func makeUIView(context: Context) -> StereoView {
        #if arch(arm) || arch(arm64)
        let stereoView = StereoView(device: context.coordinator.metalDevice)
        #else
        let stereoView = StereoView()
        #endif
        return stereoView
    }

    public func updateUIView(_ stereoView: StereoView, context: Context) {
        stereoView.stereoParameters = stereoParameters
        stereoView.technique = technique
        switch source {
        case .image(let image):
            stereoView.load(image, format: format)
        case .video(let player):
            stereoView.load(player, format: format)
        case .scene(let scene):
            stereoView.scene = scene
        }
    }

    public static func dismantleUIView(_ stereoView: StereoView, coordinator: Coordinator) {
        stereoView.isPlaying = false
        stereoView.scene = nil
        stereoView.sceneRendererDelegate = nil
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator {
        let metalDevice: MTLDevice

        init() {
            metalDevice = MTLCreateSystemDefaultDevice()!
        }
    }
}
