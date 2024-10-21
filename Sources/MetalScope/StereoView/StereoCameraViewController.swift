//
//  StereoCameraViewController.swift
//
//
//  Created by Mathijs Bernson on 18/06/2024.
//

import Foundation
import UIKit
import MetalKit
import ARKit

extension MTKView: RenderDestinationProvider {
}

public class StereoCameraViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
    var device: MTLDevice?
    let session = ARSession()
    var renderer: StereoARRenderer?

    init(device: MTLDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func loadView() {
        view = MTKView(frame: .zero, device: device)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        session.delegate = self

        // Set the view to use the default device
        if let view = self.view as? MTKView {
            view.backgroundColor = UIColor.clear
            view.delegate = self

            guard view.device != nil else {
                print("Metal is not supported on this device")
                return
            }

            do {
                // Configure the renderer to draw to the view
                let renderer = try StereoARRenderer(session: session, metalDevice: view.device!, renderDestination: view)
                renderer.drawRectResized(size: view.bounds.size)
                self.renderer = renderer
            } catch {
                print("Setup error: \(error.localizedDescription)")
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        session.run(configuration)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        session.pause()
    }

    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let currentFrame = session.currentFrame {

            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)

            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            session.add(anchor: anchor)
        }
    }

    // MARK: - MTKViewDelegate

    // Called whenever view changes orientation or layout is changed
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer?.drawRectResized(size: size)
    }

    // Called whenever the view needs to render
    public func draw(in view: MTKView) {
        renderer?.update()
    }

    // MARK: - ARSessionDelegate

    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        presentError(error)
    }

    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    func presentError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error occurred",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
}
