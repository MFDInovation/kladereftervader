//
//  ImageHandler.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit
import Foundation

enum Clothing: String{
    
    case mycketKallt = "kängor, varma strumpor, Underställ, täckbyxor, varm tröja, varm jacka, varma vantar, varm mössa, halsduk"
    case kallt = "kängor, Underställ, tröja, varm jacka, vantar, mössa, halsduk"
    case nollgradigt = "Kängor, Varm jacka, halsduk, mössa, vantar"
    case nollgradigtRegn = "kängor, Varm jacka, halsduk, mössa, vantar, paraply"
    case kyligt = "gympaskor, Jacka"
    case kyligtRegn = "stövlar, Regnkläder, tröja"
    case varmt = "t-shirt, shorts, skor"
    case varmtRegn = "t-shirt, shorts, skor, regnkläder"
    case hett = "t-shirt, shorts, sandaler"
    case hettRegn = "t-shirt, shorts, sandaler, paraply"
    
    case errorNetwork = "Kunde inte ladda väderdata"
    case errorGPS = "Kunde inte hitta din plats"
    
    var image: UIImage{
        get{
            switch self {
            case .mycketKallt: return #imageLiteral(resourceName: "minus20")
            case .kallt: return #imageLiteral(resourceName: "minus10")
            case .nollgradigt: return #imageLiteral(resourceName: "plus0")
            case .nollgradigtRegn: return #imageLiteral(resourceName: "plus0N")
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
        case (-100)..<(-15): return .mycketKallt
        case (-15)..<(-5): return .kallt
        case (-5)..<(5): return (weather.rainfall > 0) ? .nollgradigtRegn : .nollgradigt
        case (5)..<(15): return (weather.rainfall > 0) ? .kyligtRegn : .kyligt
        case (15)..<(25): return (weather.rainfall > 0) ? .varmtRegn : .varmt
        case (25)..<(100): return (weather.rainfall > 0) ? .hettRegn : .hett
        default:
            return .nollgradigtRegn
        }
    }
}




class ClothesImageHandler {
    
    static let shared = ClothesImageHandler()
    private let fileManager = FileManager.default
    private let settings = UserDefaults.standard
    
    
    // Mark: Path helper
    private var basePath: String {
        get{
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        }
    }
    
    private func getImagePathsFor(_ clothesImage: Clothing) -> [String] {
        return getUserDefaultsObject()[clothesImage.rawValue] ?? []
    }
    
    // Mark: persistent storage helper
    let userDefaultsKey = "ClothesImageHandler"
    private func getUserDefaultsObject() -> [String:[String]]{
        return settings.object(forKey: userDefaultsKey) as? [String:[String]] ?? [:]
    }
    
    private func setUserDefaultsObject(_ value: [String:[String]]) {
        settings.set(value, forKey: userDefaultsKey)
        settings.synchronize()
    }

    
    // Mark: Public image functions
    public func removeImageFor(_ clothesImage: Clothing, index: Int){
        var tmp = getUserDefaultsObject()
        if let path = tmp[clothesImage.rawValue]?[safe: index]{
            try? fileManager.removeItem(atPath: path)
        }
        tmp[clothesImage.rawValue]?.remove(at: index)
        setUserDefaultsObject(tmp)
    }
    
    public func addImageFor(_ clothesImage: Clothing, image: UIImage){
        var tmp = getUserDefaultsObject()
        let fileName = UUID().uuidString + ".jpg"
        if tmp[clothesImage.rawValue] != nil{
            tmp[clothesImage.rawValue]?.append(fileName)
        }else{
            tmp[clothesImage.rawValue] = [fileName]
        }
        do{
            guard let jpg = UIImageJPEGRepresentation(image, 0.7) else { throw NSError(domain: "jpg error", code: 1, userInfo: [:]) }
            try jpg.write(to: URL(fileURLWithPath: basePath+"/"+fileName))
            setUserDefaultsObject(tmp)
        } catch (let error){
            print(error)
        }
    }
    
    public func replaceImageFor(_ clothesImage: Clothing, image: UIImage, index: Int){
        var tmp = getUserDefaultsObject()
        let fileName = tmp[clothesImage.rawValue]![index]
        do{
            guard let jpg = UIImageJPEGRepresentation(image, 0.7) else { throw NSError(domain: "jpg error", code: 1, userInfo: [:]) }
            try jpg.write(to: URL(fileURLWithPath: basePath+"/"+fileName))
            
        } catch (let error){
            print(error)
        }
    }
    
    public func getImagesFor(_ clothesImage: Clothing) -> [UIImage]{
        let fileNames = getImagePathsFor(clothesImage)
        let images = fileNames.flatMap {
            fileName in
            return UIImage(contentsOfFile: basePath+"/"+fileName)
        }
        return images
    }
}



