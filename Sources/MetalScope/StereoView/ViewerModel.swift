//
//  ViewerModel.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/23.
//  Copyright © 2017 eje Inc. All rights reserved.
//

public struct ViewerModel: ViewerParametersProtocol {
    public let lenses: Lenses
    public let distortion: Distortion
    public let maximumFieldOfView: FieldOfView

    public init(lenses: Lenses, distortion: Distortion, maximumFieldOfView: FieldOfView) {
        self.lenses = lenses
        self.distortion = distortion
        self.maximumFieldOfView = maximumFieldOfView
    }

    static func custom(parameters: ViewerParametersProtocol) -> ViewerModel {
        return ViewerModel(lenses: parameters.lenses, distortion: parameters.distortion, maximumFieldOfView: parameters.maximumFieldOfView)
    }

    public static let cardboardJun2014 = ViewerModel(
        lenses: Lenses(separation: 0.060, offset: 0.035, alignment: .bottom, screenDistance: 0.042),
        distortion: Distortion(k1: 0.441, k2: 0.156),
        maximumFieldOfView: FieldOfView(all: 40.0)
    )
    public static let cardboardMay2015 = ViewerModel(
        lenses: Lenses(separation: 0.064, offset: 0.035, alignment: .bottom, screenDistance: 0.039),
        distortion: Distortion(k1: 0.34, k2: 0.55),
        maximumFieldOfView: FieldOfView(all: 60.0)
    )
    public static let vrBoxVR02 = ViewerModel(
        lenses: Lenses(separation: 0.070, offset: 0.05, alignment: .center, screenDistance: 0.050),
        distortion: Distortion(k1: 0.16, k2: 0.12),
        maximumFieldOfView: FieldOfView(all: 60.0)
    )

    public static let `default` = ViewerModel.cardboardMay2015
}
