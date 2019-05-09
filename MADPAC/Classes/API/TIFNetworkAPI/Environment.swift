//
//  Environment.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

public let currentEnvironment = Environments.production

public enum Environments {
    case production
    case acceptance
    
    public var ApiUri: URL {
        switch self {
        case .acceptance, .production:
            return URL(string: "https://www.madpac.nl/wp-json/api/v1/")!
        }
    }
}
