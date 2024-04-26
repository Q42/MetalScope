//
//  ScreenModel.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/23.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import UIKit

public struct ScreenModel: ScreenParametersProtocol, Decodable {
    /// In 1/1000 of millimeters
    public let width: Float
    /// In 1/1000 of millimeters
    public let height: Float
    /// In 1/1000 of millimeters
    public let border: Float

    private init(width: Float, height: Float, border: Float) {
        self.width = width
        self.height = height
        self.border = border
    }

    /// Convenience initializer that uses whole millimeters as units
    private init(widthMM: Int, heightMM: Int, borderMM: Int) {
        self.width = Float(widthMM) / 1000
        self.height = Float(heightMM) / 1000
        self.border = Float(borderMM) / 1000
    }

    static func custom(parameters: ScreenParametersProtocol) -> ScreenModel {
        ScreenModel(width: parameters.width, height: parameters.height, border: parameters.border)
    }

    public static let iPhone4 = ScreenModel(width: 0.075, height: 0.050, border: 0.0045)
    public static let iPhone5 = ScreenModel(width: 0.089, height: 0.050, border: 0.0045)
    public static let iPhone6 = ScreenModel(width: 0.104, height: 0.058, border: 0.005)
    public static let iPhone6Plus = ScreenModel(width: 0.112, height: 0.068, border: 0.005)
    public static let iPhoneX = ScreenModel(width: 0.133, height: 0.063, border: 0.005)

    public static let iPhone4S = ScreenModel.iPhone4
    public static let iPhone5s = ScreenModel.iPhone5
    public static let iPhone5c = ScreenModel.iPhone5
    public static let iPhoneSE = ScreenModel.iPhone5
    public static let iPhone6s = ScreenModel.iPhone6
    public static let iPhone6sPlus = ScreenModel.iPhone6Plus
    public static let iPhone7 = ScreenModel.iPhone6
    public static let iPhone7Plus = ScreenModel.iPhone6Plus
    public static let iPodTouch = ScreenModel.iPhone5

    public static var `default`: ScreenModel {
        return ScreenModel.current ?? .iPhone6
    }

    public static var current: ScreenModel? {
        return ScreenModel(modelIdentifier: currentModelIdentifier) ?? ScreenModel(screen: .main)
    }

    private static var currentModelIdentifier: String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine: [CChar] = Array(repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    private init?(modelIdentifier identifier: String) {
        func match(_ identifier: String, _ prefixes: [String]) -> Bool {
            return prefixes.filter({ identifier.hasPrefix($0) }).count > 0
        }

        if match(identifier, ["iPhone3"]) {
            self = .iPhone4
        } else if match(identifier, ["iPhone4"]) {
            self = .iPhone4S
        } else if match(identifier, ["iPhone5"]) {
            self = .iPhone5
        } else if match(identifier, ["iPhone6"]) {
            self = .iPhone5s
        } else if match(identifier, ["iPhone8,4"]) {
            self = .iPhoneSE
        } else if match(identifier, ["iPhone7,2"]) {
            self = .iPhone6
        } else if match(identifier, ["iPhone8,1"]) {
            self = .iPhone6s
        } else if match(identifier, ["iPhone9,1", "iPhone9,3"]) {
            self = .iPhone7
        } else if match(identifier, ["iPhone7,1"]) {
            self = .iPhone6Plus
        } else if match(identifier, ["iPhone8,2"]) {
            self = .iPhone6sPlus
        } else if match(identifier, ["iPhone9,2", "iPhone9,4"]) {
            self = .iPhone7Plus
        } else if match(identifier, ["iPhone10,3", "iPhone10,6"]) {
            self = .iPhoneX
        } else if match(identifier, ["iPod7,1"]) {
            self = .iPodTouch
        } else {
            return nil
        }
    }

    private init?(screen: UIScreen) {
        switch screen.fixedCoordinateSpace.bounds.size {
        case CGSize(width: 320, height: 480):
            self = .iPhone4
        case CGSize(width: 320, height: 568):
            self = .iPhone5
        case CGSize(width: 375, height: 667):
            self = .iPhone6
        case CGSize(width: 414, height: 768):
            self = .iPhone6Plus
        default:
            return nil
        }
    }
}
