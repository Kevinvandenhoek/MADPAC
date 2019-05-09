//
//  Observable+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 24/05/16.
//
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    
    public func doOnSubscribe(_ callback: @escaping () -> Void) -> PrimitiveSequence<Trait, E> {
        return self.do(
            onSuccess: nil,
            onError: nil,
            onSubscribe: {
                callback()
            },
            onSubscribed: nil,
            onDispose: nil
        )
    }
    
    public func doOnNext(_ callback: @escaping (E) -> Void) -> PrimitiveSequence<Trait, E> {
        return self.do(onSuccess: { (element) in
            callback(element)
        })
    }
    
    public func doOnError(_ callback: @escaping (_ error: Swift.Error) -> Void) -> PrimitiveSequence<Trait, E> {
        return self.do(
            onSuccess: nil,
            onError: { (error) in
                callback(error)
            },
            onSubscribe: nil,
            onSubscribed: nil,
            onDispose: nil
        )
    }
    
    @available(*, deprecated, message: "doOnCompleted is not longer supported. Use onSuccess")
    public func doOnCompleted(_ nextClosure:@escaping () -> Void) -> PrimitiveSequence<Trait, E> {
        return self.do(onSuccess: { _ in
            nextClosure()
        })
    }
    
    public func doOnSubscribed(_ callback: @escaping () -> Void) -> PrimitiveSequence<Trait, E> {
        return self.do(
            onSuccess: nil,
            onError: nil,
            onSubscribe: nil,
            onSubscribed: {
                callback()
            },
            onDispose: nil
        )
    }
    
    public func doOnDispose(_ callback: @escaping () -> Void) -> PrimitiveSequence<Trait, E> {
        return self.do(
            onSuccess: nil,
            onError: nil,
            onSubscribe: nil,
            onSubscribed: nil,
            onDispose: {
                callback()
            }
        )
    }
}

public extension Observable {
    
    public func doOnSubscribe(_ callback: @escaping () -> Void) -> Observable<E> {
        return self.do(onSubscribe: {
            callback()
        })
    }
    
    public func doOnNext(_ callback: @escaping (E) -> Void) -> Observable<E> {
        return self.do(onNext: { (element) in
            callback(element)
        })
    }
    
    public func doOnCompleted(_ callback: @escaping () -> Void) -> Observable<E> {
        return self.do(onCompleted: {
            callback()
        })
    }
    
    public func doOnError(_ callback: @escaping (_ error: Swift.Error) -> Void) -> Observable<E> {
        return self.do(onError: { (error) in
            callback(error)
        })
    }
}
