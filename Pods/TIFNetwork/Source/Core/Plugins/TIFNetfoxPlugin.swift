//
//  TIFNetfoxPlugin.swift
//  Pods
//
//  Created by Antoine van der Lee on 08/03/16.
//
//

import Moya
import Result

public typealias TIFEndpointClosure = (TIFAPI) -> URLRequest

protocol MoyaNetfoxPlugin {
    func nfx_save(urlRequest:URLRequest)
    func nfx_handle(result:Result<Moya.Response, MoyaError>, forRequest request:URLRequest)
    func nfx_isStarted() -> Bool
}

extension MoyaNetfoxPlugin {
    func nfx_save(urlRequest:URLRequest) {}
    func nfx_handle(result:Result<Moya.Response, MoyaError>, forRequest request:URLRequest) {}
    func nfx_isStarted() -> Bool { return false }
}

public final class TIFNetfoxPlugin : MoyaNetfoxPlugin {
    
    var modelsDict = [Int: AnyObject]()
    private let endpointClosure:TIFEndpointClosure
    
    public init(){
        self.endpointClosure = { (target) -> URLRequest in
            let url = target.baseURL.absoluteString + (target.path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? target.path)
            
            var request: URLRequest = URLRequest(url: URL(string: url)!)
            request.httpMethod = target.method.rawValue
            
            guard let parameters = target.apiMethod.defaultParameters else {
                return request
            }
            
            do {
                return try target.parameterEncoding.encode(request, with: parameters)
            } catch {
                return request
            }
        }
    }
}

extension TIFNetfoxPlugin : PluginType {
    
    /// Called by the provider as soon as the request is about to start
    public func willSend(_ request: RequestType, target: TargetType){
        guard let tifTarget = target as? TIFAPI, nfx_isStarted() else { return }
        
        let urlRequest = endpointClosure(tifTarget)
        nfx_save(urlRequest: urlRequest)
    }

    /// Called by the provider as soon as a response arrives
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType){
        guard let tifTarget = target as? TIFAPI, nfx_isStarted() else { return }
        let urlRequest = endpointClosure(tifTarget)
        
        nfx_handle(result: result, forRequest: urlRequest)
    }
}
