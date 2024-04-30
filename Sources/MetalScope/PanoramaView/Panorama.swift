//
//  Panorama.swift
//  MetalScope
//
//  Created by Mathijs Bernson on 30/04/2024.
//

import SwiftUI
import UIKit
import SceneKit
import AVFoundation

@available(iOS 13.0, *)
public struct Panorama: UIViewRepresentable {    
    let source: PanoramaSource
    let format: MediaFormat
    let technique: SCNTechnique?

    public init(image: UIImage, format: MediaFormat = .mono, technique: SCNTechnique? = nil) {
        self.source = .image(image)
        self.format = format
        self.technique = technique
    }

    public init(player: AVPlayer, format: MediaFormat = .mono, technique: SCNTechnique? = nil) {
        self.source = .video(player)
        self.format = format
        self.technique = technique
    }

    public init(scene: SCNScene, technique: SCNTechnique? = nil) {
        self.source = .scene(scene)
        self.format = .mono // Unused in this case
        self.technique = technique
    }

    public func makeUIView(context: Context) -> PanoramaView {
        #if arch(arm) || arch(arm64)
        let panoramaView = PanoramaView(frame: .zero, device: context.coordinator.device)
        #else
        let panoramaView = PanoramaView(frame: .zero)
        #endif
        return panoramaView
    }

    public func updateUIView(_ panoramaView: PanoramaView, context: Context) {
        panoramaView.technique = technique

        switch source {
        case .image(let image):
            panoramaView.load(image, format: format)
        case .video(let player):
            panoramaView.load(player, format: format)
        case .scene(let scene):
            panoramaView.scene = scene
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator {
        let device: MTLDevice

        init() {
            device = MTLCreateSystemDefaultDevice()!
        }
    }
}
