//
//  TIFAPI.swift
//  Pods
//
//  Created by Antoine van der Lee on 30/11/15.
//
//

import Foundation
import Moya

public typealias TIFGeneralErrorCallback = (_ error: MoyaError) -> ()

public protocol TIFAPI: TargetType {
    var parameterEncoding: Moya.ParameterEncoding { get }
    var apiMethod: APIMethod { get }
    var generalErrorCallback: TIFGeneralErrorCallback? { get }
    var sampleResponseCode: Int { get }
}

// Default implementations
public extension TIFAPI {
    
    var parameterEncoding: Moya.ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleResponseCode: Int {
        return 200
    }
    
    var generalErrorCallback: TIFGeneralErrorCallback? {
        return nil
    }
}

// MARK: - TargetType
public extension TIFAPI {
    
    var path: String {
        return self.apiMethod.path
    }
    
    var method: Moya.Method {
        return self.apiMethod.method
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        if let defaultParameters = self.apiMethod.defaultParameters, defaultParameters.count > 0 {
            return Task.requestParameters(parameters: defaultParameters, encoding: parameterEncoding)
        }
        
        return Task.requestPlain
    }
}

public func ==(lhs: TIFAPI, rhs: TIFAPI) -> Bool {
    return lhs.apiMethod == rhs.apiMethod
}

public func stubbedResponseFromJSON(filename: String, inDirectory subpath: String = "", bundle:Bundle? = nil ) -> Data {
    var foundPath:String? = bundle?.path(forResource: filename, ofType: "json", inDirectory: subpath)
    
    if foundPath == nil {
        for bundle in Bundle.allBundles {
            guard let path = bundle.path(forResource: filename, ofType: "json", inDirectory: subpath) else { continue }
            foundPath = path
            break
        }
    }
    
    return (try? Data(contentsOf: URL(fileURLWithPath: foundPath ?? "" ))) ?? Data()
}

public func stubbedResponseFrom(responseString: String) -> Data {
    return responseString.data(using: String.Encoding.utf8)!
}
