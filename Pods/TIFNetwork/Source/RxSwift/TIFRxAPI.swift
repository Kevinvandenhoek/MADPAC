//
//  TIFRxAPI.swift
//  Pods
//
//  Created by Antoine van der Lee on 30/11/15.
//
//

import Foundation
import Moya
import RxSwift

public protocol TIFRxAPI: TIFAPI {
    func request() -> PrimitiveSequence<SingleTrait, Moya.Response>
    func requestWithProgress() -> Observable<Moya.ProgressResponse>
}
