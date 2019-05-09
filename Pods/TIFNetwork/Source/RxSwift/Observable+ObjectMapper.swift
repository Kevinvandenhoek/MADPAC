//
//  Observable+ObjectMapper.swift
//  Pods
//
//  Created by Jeroen Bakker on 23/05/16.
//

import Foundation
import RxSwift
import Moya

public extension PrimitiveSequence where Trait == SingleTrait, E == Moya.Response {
    
    /// Maps data received from the signal into an object which implements the TIFResponseWrapper protocol.
    /// If the conversion fails or the init fails, the signal errors.
    ///
    /// - Parameter type: type the value needs to decoded to
    /// - Returns: Primitive sequence with decoded value or MoyaError
    public func mapResponse<T: TIFResponseWrapper>(_ type: T.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> Single<T> {
        return flatMap({ (response) -> Single<T> in
            var jsonResponse: T?
            
            do {
                jsonResponse = try response.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
            } catch {
                throw MoyaError.jsonMapping(response)
            }
            
            if let wrappedError = jsonResponse?.error {
                throw MoyaError.underlying(wrappedError, response)
            } else if var jsonResponse = jsonResponse {
                jsonResponse.innerResponseObject = response
                return Single.just(jsonResponse)
            } else {
                throw MoyaError.jsonMapping(response)
            }
        })
    }
}

public extension ObservableType where E == Moya.Response {

    /// Maps data received from the signal into an object which implements the TIFResponseWrapper protocol.
    /// If the conversion fails or the init fails, the signal errors.
    ///
    /// - Parameter type: type the value needs to decoded to
    /// - Returns: Observable with decoded value or MoyaError
    public func mapResponse<T: TIFResponseWrapper>(_ type: T.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> Observable<T> {
        return flatMapLatest({ (response) -> Observable<T> in
            var jsonResponse: T?
            
            do {
                jsonResponse = try response.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
            } catch {
                throw MoyaError.jsonMapping(response)
            }
            
            if let wrappedError = jsonResponse?.error {
                throw MoyaError.underlying(wrappedError, response)
            } else if var jsonResponse = jsonResponse {
                jsonResponse.innerResponseObject = response
                return Observable.just(jsonResponse)
            } else {
                throw MoyaError.jsonMapping(response)
            }
        })
    }
}

public extension PrimitiveSequence where Trait == SingleTrait, E: TIFResponseWrapper {
    
    /// Maps responsewrapper received from the signal into an object which implements the Codable protocol.
    /// If the conversion fails or the init fails, the signal errors.
    ///
    /// - Parameter type: type the value needs to decoded to
    /// - Returns: Observable with decoded value or MoyaError
    public func mapInnerResponse<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String = "o", using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> Single<T> {
        return flatMap({ (responseWrapper) -> Single<T> in
            if let wrapperInnerObject = responseWrapper.innerResponseObject {
                return Single.just(try wrapperInnerObject.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData))
            }
            
            throw TIFError.innerObjectMapping
        })
    }
}

public extension ObservableType where E: TIFResponseWrapper {
    
    /// Maps responsewrapper received from the signal into an object which implements the Codable protocol.
    /// If the conversion fails or the init fails, the signal errors.
    ///
    /// - Parameter type: type the value needs to decoded to
    /// - Returns: Observable with decoded value or MoyaError
    public func mapInnerResponse<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> Observable<T> {
        return flatMapLatest({ (responseWrapper) -> Observable<T> in
            if let wrapperInnerObject = responseWrapper.innerResponseObject {
                return Observable.just(try wrapperInnerObject.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData))
            }
            
            throw TIFError.innerObjectMapping
        })
    }
}
