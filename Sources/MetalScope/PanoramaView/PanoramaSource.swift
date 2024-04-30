//
//  PanoramaSource.swift
//
//
//  Created by Mathijs Bernson on 30/04/2024.
//

import Foundation
import UIKit
import AVFoundation
import SceneKit

enum PanoramaSource {
    case image(UIImage)
    case video(AVPlayer)
    case scene(SCNScene)
}
