//
//  TIFNetwork
//  TIFRxDataRequestView.swift
//  Pods
//

import RxSwift
import RxCocoa

public extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Attach the datarequest view to the screen when view for a network call,
    /// easy to use when waiting for a network call.
    ///
    /// - Parameter dataRequestView: view to show when loading, wants the user to reload or showing an empty view
    /// - Returns: Observable
    func attach(to dataRequestView: TIFDataRequestView) -> Single<E> {
        let resourceFactory: () throws -> BooleanDisposable = { () -> BooleanDisposable in
            return BooleanDisposable()
        }
        
        let primitiveSequenceFactory: (Disposable) throws -> Single<E> = { [weak dataRequestView] (_) throws -> Single<E> in
            dataRequestView?.changeRequestState(state: .loading)
            
            return self.observeOn(MainScheduler.instance)
                .do(onSuccess: { [weak dataRequestView] (object) in
                    if let emptyableObject = object as? Emptyable, emptyableObject.isEmpty == true {
                        dataRequestView?.changeRequestState(state: .empty)
                    } else if let arrayObject = object as? NSArray, arrayObject.count == 0 {
                        dataRequestView?.changeRequestState(state: .empty)
                    } else {
                        dataRequestView?.changeRequestState(state:.success)
                    }
                    }, onError: { [weak dataRequestView] (error) in
                        dataRequestView?.changeRequestState(state: .failed, error: error)
                    })
        }
        
        let primitiveSequence = Single.using(resourceFactory, primitiveSequenceFactory: primitiveSequenceFactory)
       
        dataRequestView.retryAction = { [weak dataRequestView] in
            if let dataRequestView = dataRequestView {
                _ = primitiveSequence.asObservable().takeUntil(dataRequestView.rx.deallocated).subscribe()
            }
        }
        
        return primitiveSequence
    }
}


public extension ObservableType {
    
    /// Attach the datarequest view to the screen when view for a network call,
    /// easy to use when waiting for a network call.
    ///
    /// - Parameter dataRequestView: view to show when loading, wants the user to reload or showing an empty view
    /// - Returns: Observable
    func attach(to dataRequestView: TIFDataRequestView) -> Observable<E> {
        let resourceFactory: () throws -> BooleanDisposable = { () -> BooleanDisposable in
            return BooleanDisposable()
        }
        
        let observableFactory:(Disposable) throws -> Observable<E> = { [weak dataRequestView] (_) throws -> Observable<E> in
            dataRequestView?.changeRequestState(state: .loading)
            
            return self.observeOn(MainScheduler.instance)
                .do(onNext: { [weak dataRequestView] (object) in
                    if let emptyableObject = object as? Emptyable, emptyableObject.isEmpty == true {
                        dataRequestView?.changeRequestState(state: .empty)
                    } else if let arrayObject = object as? NSArray, arrayObject.count == 0 {
                        dataRequestView?.changeRequestState(state: .empty)
                    } else {
                        dataRequestView?.changeRequestState(state:.success)
                    }
                }, onError: { [weak dataRequestView] (error) in
                    dataRequestView?.changeRequestState(state: .failed, error: error)
                })
        }
        
        let observable = Observable.using(resourceFactory, observableFactory: observableFactory)

        dataRequestView.retryAction = { [weak dataRequestView] () -> Void in
            if let dataRequestView = dataRequestView {
                _ = observable.takeUntil(dataRequestView.rx.deallocated).subscribe()
            }
        }
        
        return observable
    }
}
