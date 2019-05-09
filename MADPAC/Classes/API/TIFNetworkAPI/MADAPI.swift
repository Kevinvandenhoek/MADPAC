//
//  MADApi.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import TIFNetwork
import Alamofire
import Moya
import RxSwift

private let provider = TIFNetworkRxProvider<MADAPI>(plugins: [TIFNetfoxPlugin()])
private let stubProvider = TIFNetworkRxProvider<MADAPI>(plugins: [], stubClosure: MoyaProvider.immediatelyStub)

public extension MADAPI {
    
    public func request() -> PrimitiveSequence<SingleTrait, Moya.Response> {
        return provider.rx.request(self)
    }
    
    func requestWithProgress() -> Observable<Moya.ProgressResponse> {
        return provider.rx.requestWithProgress(self)
    }
    
    func stubbedRequest() -> PrimitiveSequence<SingleTrait, Moya.Response> {
        return stubProvider.rx.request(self)
    }
    
    var generalErrorCallback: TIFGeneralErrorCallback? {
        return { (error: Moya.MoyaError) -> Void in
            
        }
    }
}

public enum MADAPI: TIFRxAPI {
    case getCategories()
    case getPosts(category: String?, page: Int)
    case getSearch(term: String)
    
    public var apiMethod: APIMethod {
        switch self {
        case .getCategories:
            return APIMethod(path: "get_categories", method: .get)
        case .getPosts(let category, let page):
            let parameters: [String: Any] = [
                "category": category ?? "trending",
                "page": "\(page)",
                "app": "true"
            ]
            //let path = "get_category_posts?category=\(category ?? "trending")?page=\(page)"
            return APIMethod(path: "get_category_posts", method: .get, defaultParameters: parameters)
        case .getSearch(let term):
            let parameters: [String: Any] = [ "q": term ]
            return APIMethod(path: "search", method: .get, defaultParameters: parameters)
        }
    }
    
    public var sampleData: Data {
        return stubbedResponseFromJSON(filename: "", inDirectory: "shared_stubs", bundle: Bundle.main)
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self.apiMethod.method {
        default:
            return JSONEncoding.default
        }
    }
    
    public var headers: [String: String]? {
        return nil
    }
    
    public var baseURL: URL {
        return currentEnvironment.ApiUri
    }
}
