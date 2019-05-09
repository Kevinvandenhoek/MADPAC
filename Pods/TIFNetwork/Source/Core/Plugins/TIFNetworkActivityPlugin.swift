//
//  TIFNetworkActivityPlugin.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/02/16.
//
//

import Moya
import Result

public final class TIFNetworkActivityPlugin {
    
    public init() {}
    
    private var numberOfRequests:Int = 0 {
        didSet {
            if numberOfRequests < 0{
                numberOfRequests = 0
            }
            updateNetworkActivityIndicator()
        }
    }
    
    #if os(iOS)
    private func updateNetworkActivityIndicator() {
        DispatchQueue.main.async {
            UIApplication.sharedValue?.isNetworkActivityIndicatorVisible = self.numberOfRequests > 0
        }
    }
    #else
    private func updateNetworkActivityIndicator() { }
    #endif
}

// MARK: - PluginType
extension TIFNetworkActivityPlugin: PluginType {
    
    /// Called by the provider as soon as the request is about to start
    public func willSend(_ request: RequestType, target: TargetType) {
        numberOfRequests += 1
    }
    
    /// Called by the provider as soon as a response arrives
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        numberOfRequests -= 1
    }
}
