//
//  UIDevice+ScreenType.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-10.
//  Copyright © 2017 Knowit. All rights reserved.
//

// From https://stackoverflow.com/questions/27775779/how-to-check-screen-size-of-iphone-4-and-iphone-5-programmatically-in-swift

import UIKit

extension UIDevice {

    var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }

    enum ScreenType: String {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case Unknown
    }

    var screenType: ScreenType? {
        guard iPhone else { return nil }
        switch UIScreen.main.nativeBounds.height {
            case 960:
                return .iPhone4
            case 1136:
                return .iPhone5
            case 1334:
                return .iPhone6
            case 2208:
                return .iPhone6Plus
            default:
                return nil
        }
    }

    // Helper funcs
    static func isScreen35inch() -> Bool {
        return UIDevice().screenType == .iPhone4
    }

    static func isScreen4inch() -> Bool {
        return UIDevice().screenType == .iPhone5
    }

    static func isScreen47inch() -> Bool {
        return UIDevice().screenType == .iPhone6
    }

    static func isScreen55inch() -> Bool {
        return UIDevice().screenType == .iPhone6Plus
    }

    static func displayZoomEnabled() -> Bool {
        let screen = UIScreen.main
        return screen.scale != screen.nativeScale
    }

}
