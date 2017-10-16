//
//  JSON.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

//Class for handling errors. Especially good for asynchronous tasks
enum Response<T> {
    case success(T)
    case error(Error)
    
    //Applicerar en transform om success annars inte.
    func map<G>(_ transform: (T) -> G) -> Response<G> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .error(let error):
            return .error(error)
        }
        
    }
    
    static func flatten<T>(_ response: Response<Response<T>>) -> Response<T> {
        switch response {
        case .success(let innerResponse):
            return innerResponse
        case .error(let error):
            return .error(error)
        }
    }
    
    func flatMap<G>(_ transform: (T) -> Response<G>) -> Response<G> {
        return Response.flatten(map(transform))
    }
}

//Various methods for getting information over http(s)
class Networking {
    func getData(url:URL, _ callback: @escaping (Response<Data>) -> Void) {
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if let data = data {
                callback(.success(data))
            } else if let error = error {
                callback(.error(error))
            } else {
                callback(.error(NSError(domain: "getData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
        })
        dataTask.resume()
    }
    
    func getJson(url:URL, _ callback: @escaping (Response<Json>) -> Void) {
        getData(url: url) {
            callback($0.flatMap { data in
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                    return .success(Json(object: json))
                } catch {
                    return .error(error)
                }
            })
        }
    }
    
    func getImage(url:URL, _ callback: @escaping (Response<UIImage>) -> Void) {
        getData(url: url) {
            callback($0.flatMap{ data in
                if let image = UIImage(data: data) {
                    return .success(image)
                }
                return .error(NSError(domain: "getImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"]))
            })
        }
    }
}

//Simple class to handle json in a pretty way
//This was created to handle the switch from swift 2 to swift 3
class Json{
    
    let value:AnyObject?
    
    var string:String?  { return value as? String}
    var num:Int?  { return value as? Int}
    var double:Double?  { return value as? Double}
    var date:Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let dateString = string {
            if let date = dateFormatter.date(from: dateString){
                return date
            }
            return nil
        }
        return nil
    }
    var array:[Json]?  { return (value as? [AnyObject])?.map{ return Json(object: $0) }}
    
    public init(object:Any?){
        value = object as AnyObject?
    }
    
    public convenience init?(string:String){
        if let data = string.data(using: .utf8) {
            self.init(data: data)
        }else{
            return nil
        }
    }
    
    public convenience init?(data:Data){
        if let json = try? JSONSerialization.data(withJSONObject: data, options: []){
            self.init(object: json)
        }else{
            return nil
        }
    }
    
    public subscript(_ index: Int) -> Json {
        if let data = value as? NSArray,
            let result = data.safeObject(at:index){
            return Json(object: result)
        }
        return Json(object: nil)
    }
    
    public subscript(_ index: String) -> Json {
        if let data = value,
            let result = data[index]{
            return Json(object: result)
        }
        return Json(object: nil)
    }
}
