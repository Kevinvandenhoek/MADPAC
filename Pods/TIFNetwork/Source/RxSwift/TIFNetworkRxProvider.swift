//
//  TIFNetworkRxProvider.swift
//
//  Created by AvdLee on 17/5/16.
//  Copyright (c) 2016 Triple. All rights reserved.
//

import Moya
import RxSwift

open class TIFNetworkRxProvider<T: TIFRxAPI>: MoyaProvider<T>, TIFProvider {
    let requestSerializer: TIFURLRequestSerializer?
    let customEndpointSampleResponse: EndpointSampleResponse?
   
    public init(endpointClosure: @escaping EndpointClosure = TIFNetworkRxProvider.DefaultEndpointClosure,
                requestClosure: @escaping RequestClosure = TIFNetworkRxProvider.DefaultRequestClosure,
                requestSerializer: TIFURLRequestSerializer? = nil,
                plugins: [PluginType]? = [],
                stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                manager: Manager = MoyaProvider<T>.defaultAlamofireManager(),
                customEndpointSampleResponse: EndpointSampleResponse? = nil,
                trackInflights: Bool = false) {
        
        var stubClosure: StubClosure = stubClosure
        
        self.customEndpointSampleResponse = customEndpointSampleResponse
        self.requestSerializer = requestSerializer
        
        stubClosure = type(of: self).stubClosureForTesting() ?? stubClosure

        super.init(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure:stubClosure,
            manager: manager,
            plugins: plugins ?? [],
            trackInflights: trackInflights
        )
    }
    
    open func requestWithProgress(_ token: T) -> Observable<Moya.ProgressResponse> {
        return self.rx.requestWithProgress(token)
    }

    open func request(_ token: T) -> PrimitiveSequence<SingleTrait, Moya.Response> {
        return self.request(token, disableFilteringSuccessfulStatusCodes: false)
    }
    
    open func request(_ token: T, disableFilteringSuccessfulStatusCodes: Bool) -> PrimitiveSequence<SingleTrait, Moya.Response> {
        var observable: PrimitiveSequence<SingleTrait, Moya.Response> = rx.request(token)
        
        if disableFilteringSuccessfulStatusCodes == false {
            observable = observable.filterSuccessfulStatusCodes()
        }
        
        if let generalErrorCallback = token.generalErrorCallback {
            observable = observable.doOnError({ (error) in
                if let error = error as? MoyaError {
                    generalErrorCallback(error)
                }
            })
        }
        
        return observable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
    }
    
    open override func endpoint(_ token: T) -> Endpoint {
        return tifEndpointFor(token: token)
    }
    
    public static func DefaultEndpointClosure<T: TargetType>(_ target: T) -> Endpoint {
        return tifDefaultEndpointClosureFor(target: target)
    }
    
    public static func DefaultRequestClosure(_ endpoint: Endpoint, closure: RequestResultClosure) {
        return tifDefaultRequestClosureFor(endpoint: endpoint, closure: closure)
    }

    public static func FailedEndpointMapping<T: TargetType>(_ target: T) -> Endpoint {
        return tifFailedEndpointMappingFor(target: target)
    }
}
