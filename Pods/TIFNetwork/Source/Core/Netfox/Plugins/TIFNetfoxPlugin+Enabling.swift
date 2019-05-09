//
//  TIFNetfoxPlugin.swift
//  Pods
//
//  Created by Antoine van der Lee on 08/03/16.
//
//

import Moya
import Result
import Foundation

extension TIFNetfoxPlugin {
    func nfx_save(urlRequest: URLRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let model = NFXHTTPModel()
            model.saveRequest(urlRequest as URLRequest)
            self.modelsDict[urlRequest.hashValue] = model as AnyObject
        }
    }
    
    func nfx_handle(result:Result<Moya.Response, MoyaError>, forRequest request:URLRequest){
        guard let model = modelsDict[request.hashValue] as? NFXHTTPModel else { return }
        
        if case .success(let response) = result, let urlResponse = response.response {
            model.saveResponse(urlResponse, data: response.data)
        }
        
        NFXHTTPModelManager.sharedInstance.add(model)
    }
    
    func nfx_isStarted() -> Bool {
        return NFX.sharedInstance().started
    }
}
