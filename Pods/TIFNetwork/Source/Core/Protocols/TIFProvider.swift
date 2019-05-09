//
//  TIFProvider.swift
//  Pods
//
//  Created by Antoine van der Lee on 17/05/16.
//
//

import Foundation
import Moya
import Result

public let TIFStubbedResponsesEnabledKey = "TIFStubbedResponsesEnabledKey"

protocol TIFProvider {
    var requestSerializer: TIFURLRequestSerializer? { get }
    var customEndpointSampleResponse: EndpointSampleResponse? { get }
    
    static func stubClosureForTesting<T: TargetType>() -> MoyaProvider<T>.StubClosure?
    
    func tifEndpointFor(token: TIFAPI) -> Endpoint
    
    static func tifDefaultEndpointClosureFor<T: TargetType>(target: T) -> Endpoint
    static func tifDefaultRequestClosureFor(endpoint: Endpoint, closure: (Result<URLRequest, MoyaError>) -> Void)
    static func tifFailedEndpointMappingFor<T: TargetType>(target: T) -> Endpoint
}

extension TIFProvider {
    static func stubClosureForTesting<T: TargetType>() -> MoyaProvider<T>.StubClosure? {
        // Check if we need to stub based on UITest launch argument
        let launchArguments = ProcessInfo.processInfo.arguments
        if launchArguments.contains(TIFStubbedResponsesEnabledKey) {
            // Enable stubbing
            return MoyaProvider.immediatelyStub
        }
        
        return nil
    }
    
    func tifEndpointFor(token: TIFAPI) -> Endpoint {
        // Default values for endpoint:
        let apiMethod = token.apiMethod
        var parameters: [String: Any]?
        var responseClosure: () -> EndpointSampleResponse = {
            if let customEndpointSampleResponse = self.customEndpointSampleResponse {
                return customEndpointSampleResponse
            }
            return EndpointSampleResponse.networkResponse(token.sampleResponseCode, token.sampleData)
        }
        
        // Serialize parameters if needed
        if var tokenParameters = apiMethod.defaultParameters {
            requestSerializer?.serialize(parameters: &tokenParameters, forToken: token)
            parameters = tokenParameters
        }
        
        // Stub response if needed (based on launch arguments)
        let launchArguments = ProcessInfo.processInfo.arguments
        
        // We asume that the stubbed response key is always followed by the stubbed data
        if let stubbedResponseIndex = launchArguments.index(of: TIFStubbedResponsesEnabledKey),
            let base64MockInfo = launchArguments[safe:stubbedResponseIndex + 1] {
            // Get mockinfo from launcArguments
            let base64Decoded = Data(base64Encoded: base64MockInfo, options:Data.Base64DecodingOptions(rawValue: 0))
            let stubbedResponses = NSKeyedUnarchiver.unarchiveObject(with: base64Decoded ?? Data()) as? [TIFStubbedResponse]
            
            // Check if we have stubbed data for the targeted path
            if let matchingStubbedResponse = stubbedResponses?.filter({$0.requestPath == token.path}).first {
                
                // Error reponse
                if let error = matchingStubbedResponse.responseError {
                    responseClosure = { return EndpointSampleResponse.networkError(error as NSError) }
                }
                    
                    // Normal response
                else {
                    responseClosure = { return EndpointSampleResponse.networkResponse(
                        matchingStubbedResponse.responseCode,
                        matchingStubbedResponse.responseData ?? Data()
                        )}
                }
            }
        }
        
        let endpoint: TIFEndPoint = TIFEndPoint(
            url: urlForTarget(token, path: apiMethod.path),
            sampleResponseClosure: responseClosure,
            method: apiMethod.method,
            task: token.task,
            parameters: parameters,
            parameterEncoding: token.parameterEncoding,
            httpHeaderFields: token.headers ?? [:],
            requestSerializer: requestSerializer
        )
        
        return endpoint
    }
    
    static func tifDefaultEndpointClosureFor<T: TargetType>(target: T) -> Endpoint {
        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: {.networkResponse(200, target.sampleData)},
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    
    static func tifDefaultRequestClosureFor(endpoint: Endpoint, closure: (Result<URLRequest, MoyaError>) -> Void) {
        if let endpoint = endpoint as? TIFEndPoint, let urlRequest = endpoint.serializedUrlRequest {
            return closure(.success(urlRequest))
        }
        
        return try! closure(.success(endpoint.urlRequest()))
    }
    
    static func tifFailedEndpointMappingFor<T: TargetType>(target: T) -> Endpoint {
        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: {.networkResponse(400, target.sampleData)},
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
}

private func urlForTarget(_ target: TIFAPI, path: String) -> String {
    return target.baseURL.appendingPathComponent(path).absoluteString
}

private extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
}
