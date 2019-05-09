//
//  NFXHTTPModelManager.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation

private let _sharedInstance = NFXHTTPModelManager()

final class NFXHTTPModelManager: NSObject
{
    static let sharedInstance = NFXHTTPModelManager()
    private var models = [NFXHTTPModel]()
    
    func add(_ obj: NFXHTTPModel) {
        self.models.insert(obj, at: 0)
    }
    
    func clear() {
        self.models.removeAll()
    }

    func getModels() -> [NFXHTTPModel] {
        var predicates = [NSPredicate]()
        
        let filterValues = NFX.sharedInstance().getCachedFilters()
        let filterNames = HTTPModelShortType.allValues

        filterValues.enumerated().forEach({ (index, filterValue) in
            guard filterValue else { return }
            
            let filterName = filterNames[index].rawValue
            let predicate = NSPredicate(format: "shortType == '\(filterName)'")
            predicates.append(predicate)
        })

        return models
    }
}
