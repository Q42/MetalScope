//
//  ViewerParameters.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/23.
//  Copyright © 2017 eje Inc. All rights reserved.
//

public protocol ViewerParametersProtocol {
    var lenses: Lenses { get }
    var distortion: Distortion { get }
    var maximumFieldOfView: FieldOfView { get }
}

public struct ViewerParameters: ViewerParametersProtocol {
    public var lenses: Lenses
    public var distortion: Distortion
    public var maximumFieldOfView: FieldOfView

    public init(lenses: Lenses, distortion: Distortion, maximumFieldOfView: FieldOfView) {
        self.lenses = lenses
        self.distortion = distortion
        self.maximumFieldOfView = maximumFieldOfView
    }

    public init(_ parameters: ViewerParametersProtocol) {
        self.lenses = parameters.lenses
        self.distortion = parameters.distortion
        self.maximumFieldOfView = parameters.maximumFieldOfView
    }
}

public struct Lenses {
    public enum Alignment: Int {
        case top = -1
        case center = 0
        case bottom = 1
    }

    public let separation: Float
    public let offset: Float
    public let alignment: Alignment

    public let screenDistance: Float

    public init(separation: Float, offset: Float, alignment: Alignment, screenDistance: Float) {
        self.separation = separation
        self.offset = offset
        self.alignment = alignment
        self.screenDistance = screenDistance
    }
}

/// Models the field of view, expressed in degrees.
public struct FieldOfView {
    /// In degrees
    public let outer: Float
    /// In degrees
    public let inner: Float
    /// In degrees
    public let upper: Float
    /// In degrees
    public let lower: Float

    public init(outer: Float, inner: Float, upper: Float, lower: Float) {
        self.outer = outer
        self.inner = inner
        self.upper = upper
        self.lower = lower
    }

    public init(all fov: Float) {
        self.outer = fov
        self.inner = fov
        self.upper = fov
        self.lower = fov
    }

    public init(values: [Float]) {
        guard values.count == 4 else {
            fatalError("The values must contain 4 elements")
        }
        outer = values[0]
        inner = values[1]
        upper = values[2]
        lower = values[3]
    }
}

/// Models the distortion of the lenses.
/// https://en.wikipedia.org/wiki/Distortion_(optics)
public struct Distortion {
    /// k1 is the radial distortion coefficient of the first order
    public var k1: Float
    /// k2 can be used to counteract the main distortion at the periphery of the image
    public var k2: Float

    public init(k1: Float, k2: Float) {
        self.k1 = k1
        self.k2 = k2
    }

    public init(values: [Float]) {
        guard values.count == 2 else {
            fatalError("The values must contain 2 elements")
        }
        k1 = values[0]
        k2 = values[1]
    }

    public func distort(_ r: Float) -> Float {
        let r2 = r * r
        return ((k2 * r2 + k1) * r2 + 1) * r
    }

    public func distortInv(_ r: Float) -> Float {
        var r0: Float = 0
        var r1: Float = 1
        var dr0 = r - distort(r0)
        while abs(r1 - r0) > Float(0.0001) {
            let dr1 = r - distort(r1)
            let r2 = r1 - dr1 * ((r1 - r0) / (dr1 - dr0))
            r0 = r1
            r1 = r2
            dr0 = dr1
        }
        return r1
    }
}
