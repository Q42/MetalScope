//
//  StereoCamera.swift
//
//
//  Created by Mathijs Bernson on 18/06/2024.
//

import Foundation
import SwiftUI
import SceneKit

@available(iOS 13.0, *)
public struct StereoCamera: UIViewControllerRepresentable {
    let format: MediaFormat
    let stereoParameters: StereoParameters
    let technique: SCNTechnique?

    public init(
        format: MediaFormat = .mono,
        parameters: StereoParameters = StereoParameters(),
        technique: SCNTechnique? = nil
    ) {
        self.format = format
        self.stereoParameters = parameters
        self.technique = technique
    }

    public func makeUIViewController(context: Context) -> StereoCameraViewController {
        #if arch(arm) || arch(arm64)
        let controller = StereoCameraViewController(device: context.coordinator.metalDevice)
        #else
        let controller = StereoCameraViewController()
        #endif
        return controller
    }

    public func updateUIViewController(_ controller: StereoCameraViewController, context: Context) {
    }

    public static func dismantleUIViewController(_ controller: StereoCameraViewController, coordinator: Coordinator) {
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
