//
//  ImageHandler.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit
import Foundation

enum Clothing: String {
    
    case mycketKallt = "underställ, varma strumpor, täckbyxor, varm tröja, vinterkängor eller vinterstövlar, varm jacka, vintermössa, tjocka vantar, halsduk "
    case mycketKalltSno = "underställ, varma strumpor, täckbyxor, varm tröja, vinterkängor eller vinterstövlar, varm jacka, vintermössa, tjocka vantar, halsduk"
    case kallt = "underställ, varma byxor, tröja, varma kängor, varm jacka, mössa, vantar, halsduk"
    case kalltSno = "underställ, täckbyxor, tröja, varma kängor, varm jacka, mössa, vantar, halsduk"
    case nollgradigtMinus = "tröja, kängor, varm jacka, mössa, vantar, halsduk"
    case nollgradigtMinusSno = "tröja, kängor, varm jacka, mössa, vantar, halsduk "
    case nollgradigtPlus = "tröja, kängor, varm jacka, mössa, vantar, halsduk  "
    case nollgradigtPlusRegn = "tröja, kängor, varm jacka, mössa, vantar, halsduk, paraply eller regnjacka"
    case kyligt = "långbyxor, tröja, skor, jacka"
    case kyligtRegn = "långbyxor, tröja, stövlar, regnkläder"
    case varmt = "shorts, t-shirt, skor, extra tröja"
    case varmtRegn = "shorts, t-shirt, skor eller stövlar, regnjacka"
    case hett = "shorts, t-shirt, sandaler"
    case hettRegn = "shorts, t-shirt, sandaler, regnjacka"
    
    case errorNetwork = "Kunde inte ladda väderdata"
    case errorGPS = "Kunde inte hitta din plats"
    
    public static let allValues = [mycketKallt,
                            mycketKalltSno,
                            kallt,
                            kalltSno,
                            nollgradigtMinus,
                            nollgradigtMinusSno,
                            nollgradigtPlus,
                            nollgradigtPlusRegn,
                            kyligt,
                            kyligtRegn,
                            varmt,
                            varmtRegn,
                            hett,
                            hettRegn]
    
    var image: UIImage {
        get {
            switch self {
            case .mycketKallt: return #imageLiteral(resourceName: "minus20")
            case .mycketKalltSno: return #imageLiteral(resourceName: "minus20")
            case .kallt: return #imageLiteral(resourceName: "minus10")
            case .kalltSno: return #imageLiteral(resourceName: "minus10")
            case .nollgradigtMinus: return #imageLiteral(resourceName: "minus10")
            case .nollgradigtMinusSno: return #imageLiteral(resourceName: "minus10")
            case .nollgradigtPlus: return #imageLiteral(resourceName: "plus0")
            case .nollgradigtPlusRegn: return #imageLiteral(resourceName: "plus0N")
            case .kyligt: return #imageLiteral(resourceName: "plus10")
            case .kyligtRegn: return #imageLiteral(resourceName: "plus10N")
            case .varmt: return #imageLiteral(resourceName: "plus20")
            case .varmtRegn: return #imageLiteral(resourceName: "plus20N")
            case .hett: return #imageLiteral(resourceName: "plus25")
            case .hettRegn: return #imageLiteral(resourceName: "plus25N")
            case .errorNetwork: return #imageLiteral(resourceName: "internet_error")
            case .errorGPS: return #imageLiteral(resourceName: "gps_error")
            }
        }
    }
 
    static func create(from weather:Weather) -> Clothing {
        switch weather.temperature {
        case (-100)..<(-15): return (weather.rainfall > 0) ? .mycketKalltSno : .mycketKallt
        case (-15)..<(-5): return (weather.rainfall > 0) ? .kalltSno : .kallt
        case (-5)..<0: return (weather.rainfall > 0) ? .nollgradigtMinusSno : .nollgradigtMinus
        case 0..<(5): return (weather.rainfall > 0) ? .nollgradigtPlusRegn : .nollgradigtPlus
        case (5)..<(15): return (weather.rainfall > 0) ? .kyligtRegn : .kyligt
        case (15)..<(25): return (weather.rainfall > 0) ? .varmtRegn : .varmt
        case (25)..<(100): return (weather.rainfall > 0) ? .hettRegn : .hett
        default:
            return .nollgradigtPlusRegn
        }
    }
}




class ClothesImageHandler {
    
    static let shared = ClothesImageHandler()
    private let fileManager = FileManager.default
    private let settings = UserDefaults.standard
    
    
    // Mark: Path helper
    private var basePath: String {
        get {
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        }
    }

    private func getImageNamesFor(_ clothesImage: Clothing) -> [String] {
        return getUserDefaultsObject()[clothesImage.rawValue] ?? []
    }

    // Mark: persistent storage helper
    let userDefaultsKey = "ClothesImageHandler"
    private func getUserDefaultsObject() -> [String:[String]] {
        return settings.object(forKey: userDefaultsKey) as? [String:[String]] ?? [:]
    }
    
    private func setUserDefaultsObject(_ value: [String:[String]]) {
        settings.set(value, forKey: userDefaultsKey)
        settings.synchronize()
    }

    
    // Mark: Public image functions
    public func removeImageFor(_ clothesImage: Clothing, index: Int) {
        var tmp = getUserDefaultsObject()
        if let path = tmp[clothesImage.rawValue]?[safe: index] {
            try? fileManager.removeItem(atPath: path)
        }
        tmp[clothesImage.rawValue]?.remove(at: index)
        setUserDefaultsObject(tmp)
    }
    
    public func addImageFor(_ clothesImage: Clothing, image: UIImage) {
        var tmp = getUserDefaultsObject()
        let fileName = UUID().uuidString + ".jpg"
        if tmp[clothesImage.rawValue] != nil {
            tmp[clothesImage.rawValue]?.append(fileName)
        } else {
            tmp[clothesImage.rawValue] = [fileName]
        }
        do {
            guard let jpg = UIImageJPEGRepresentation(image, 0.7) else { throw NSError(domain: "jpg error", code: 1, userInfo: [:]) }
            try jpg.write(to: URL(fileURLWithPath: basePath+"/"+fileName))
            setUserDefaultsObject(tmp)
        } catch (let error) {
            print(error)
        }
    }
    
    public func replaceImageFor(_ clothesImage: Clothing, image: UIImage, index: Int) {
        var tmp = getUserDefaultsObject()
        let fileName = tmp[clothesImage.rawValue]![index]
        do {
            guard let jpg = UIImageJPEGRepresentation(image, 0.7) else { throw NSError(domain: "jpg error", code: 1, userInfo: [:]) }
            try jpg.write(to: URL(fileURLWithPath: basePath+"/"+fileName))
        } catch (let error) {
            print(error)
        }
    }

    public func getImagePathsFor(_ clothesImage: Clothing) -> [String] {
        let fileNames = getImageNamesFor(clothesImage)
        let filePaths = fileNames.flatMap {
            fileName in
            return basePath+"/"+fileName
        }
        return filePaths
    }
    
    public func getImagesFor(_ clothesImage: Clothing) -> [UIImage] {
        let fileNames = getImageNamesFor(clothesImage)
        let images = fileNames.flatMap {
            fileName in
            return UIImage(contentsOfFile: basePath+"/"+fileName)
        }
        return images
    }
}



