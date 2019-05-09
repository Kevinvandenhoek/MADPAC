//
//  TIFEndPoint.swift
//  Pods
//
//  Created by Antoine van der Lee on 30/11/15.
//
//

import Foundation
import Moya

public final class TIFEndPoint: Endpoint {
    let requestSerializer: TIFURLRequestSerializer?
    
    init(url: String,
            sampleResponseClosure: @escaping SampleResponseClosure,
            method: Moya.Method = Moya.Method.get,
            task: Task,
            parameters: [String: Any]? = nil,
            parameterEncoding: Moya.ParameterEncoding = URLEncoding.default,
            httpHeaderFields: [String: String]? = nil,
            requestSerializer: TIFURLRequestSerializer? = nil) {
        self.requestSerializer = requestSerializer
        
        guard requestSerializer != nil, let parameters = parameters else {
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: task, httpHeaderFields: httpHeaderFields)
            return
        }
        
        switch task {
        case .requestPlain:
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestParameters(parameters: parameters, encoding: parameterEncoding), httpHeaderFields: httpHeaderFields)
        case .requestData(let data):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestData(data), httpHeaderFields: httpHeaderFields)
        case .requestJSONEncodable(let encodable):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestJSONEncodable(encodable), httpHeaderFields: httpHeaderFields)
        case .requestCustomJSONEncodable(let encodable, let encoder):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestCustomJSONEncodable(encodable, encoder: encoder), httpHeaderFields: httpHeaderFields)
        case .requestParameters(_, _):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestParameters(parameters: parameters, encoding: parameterEncoding), httpHeaderFields: httpHeaderFields)
        case .requestCompositeData(let bodyData, _):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestCompositeData(bodyData: bodyData, urlParameters: parameters), httpHeaderFields: httpHeaderFields)
        case .requestCompositeParameters(let bodyParameters, let bodyEncoding, _):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding, urlParameters: parameters), httpHeaderFields: httpHeaderFields)
        case .uploadFile(let fileUrl):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .uploadFile(fileUrl), httpHeaderFields: httpHeaderFields)
        case .uploadMultipart(let multiPart):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .uploadCompositeMultipart(multiPart, urlParameters: parameters), httpHeaderFields: httpHeaderFields)
        case .uploadCompositeMultipart(let multiPart, _):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .uploadCompositeMultipart(multiPart, urlParameters: parameters), httpHeaderFields: httpHeaderFields)
        case .downloadDestination(let destination):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .downloadDestination(destination), httpHeaderFields: httpHeaderFields)
        case .downloadParameters(_, _, let destination):
            super.init(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: .downloadParameters(parameters: parameters, encoding: parameterEncoding, destination: destination), httpHeaderFields: httpHeaderFields)
        }
    }
    
    public var serializedUrlRequest: URLRequest? {
        guard let requestSerializer = requestSerializer else {
            return try? urlRequest()
        }
        return try? requestSerializer.serialize(request: urlRequest())
    }
}
