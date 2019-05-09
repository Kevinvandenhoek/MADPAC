//
//  MADSimpleAPI.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

class MADSimpleAPI {
    static let session = URLSession(configuration: .default)
    
    static func request(with path: String, parameters: [String: String], completion: ((Data?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var completePath = "http://www.madpac.nl/wp-json/api/v1/\(path)"
            for (index, parameter) in parameters.enumerated() {
                let first = index == 0
                completePath = completePath + "\(first ? "?" : "&")\(parameter.key)=\(parameter.value)"
            }
            completePath = completePath.replacingOccurrences(of: " ", with: "%20")
            print("Requesting from \(completePath)")
            let request = URLRequest(url: URL(string: completePath)!) // TODO: Could be a sneaky crash
            
            let task = session.dataTask(with: request) { (data, _, _) in
                completion?(data)
            }
            
            task.resume()
        }
    }
    
    static func getAppInit(completion: ((Data?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var path = "https://www.madpac.nl/api/menus/get_menu/?menu_id=314"
            let request = URLRequest(url: URL(string: path)!) // TODO: Could be a sneaky crash
            
            let task = session.dataTask(with: request) { (data, _, _) in
                completion?(data)
            }
            
            task.resume()
        }
    }
}
