//
//  CollectionViewUpdater.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 11/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionViewUpdaterDelegate: AnyObject {
    func getCurrentItems<T: Equatable>() -> [T] // Return the current items from the vc
    func appendToItems<T: Equatable>(itemsToAppend: [T]) // Add these to your items in the vc
    func removeFromItems<T: Equatable>(itemsToRemove: [T]) // Remove these from your items in the vc
    func didCompleteUpdates()
}

class CollectionViewUpdater<T: Equatable> {
    
    private let collectionView: UICollectionView
    private let delegate: CollectionViewUpdaterDelegate
    
    private var itemsToInsertPool: [T] = []
    private var itemsToRemovePool: [T] = []
    
    private var isUpdating: Bool = false { didSet { updateIfNeeded() } }
    
    var isInterviews: Bool = false
    
    init(for collectionView: UICollectionView, and delegate: CollectionViewUpdaterDelegate) {
        self.delegate = delegate
        self.collectionView = collectionView
    }
    
    func add(items: [T]) {
        itemsToInsertPool += items
        updateIfNeeded()
    }
    
    func remove(items: [T]) {
        itemsToRemovePool += items
        updateIfNeeded()
    }
    
    func addAndRemove(itemsToAdd: [T], itemsToRemove: [T]) {
        itemsToInsertPool += itemsToAdd
        itemsToRemovePool += itemsToRemove
        updateIfNeeded()
    }
    
    func updateIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self, !self.isUpdating else { return }
            if self.itemsToInsertPool.count > 0 || self.itemsToRemovePool.count > 0 {
                self.updateCollectionView()
            }
        }
    }
    
    private func updateCollectionView() {
        guard !isUpdating else { return }
        isUpdating = true
        
        let itemsToInsert: [T] = drawFrom(pool: &itemsToInsertPool)
        let itemsToDelete: [T] = drawFrom(pool: &itemsToRemovePool)
        
        guard itemsToInsert.count > 0 || itemsToDelete.count > 0 else { return }

        let bugIsResolved = isInterviews ? false : collectionView.numberOfItems(inSection: 0) > 0
        if bugIsResolved { // TODO: The part below should also work at 0 items but doesnt for some reason
            collectionView.performBatchUpdates({

                collectionView.deleteItems(at: getIndexPathsFor(items: itemsToDelete))
                delegate.removeFromItems(itemsToRemove: itemsToDelete)
                
                delegate.appendToItems(itemsToAppend: itemsToInsert)
                collectionView.insertItems(at: getIndexPathsFor(items: itemsToInsert))
                
            }) { (completed) in
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    if !completed {
                        print("CollectionViewUpdater: Failed to complete batch updates")
                        self.delegate.removeFromItems(itemsToRemove: itemsToInsert)
                        self.delegate.appendToItems(itemsToAppend: itemsToDelete)
                    }
                    self.isUpdating = false
                    self.delegate.didCompleteUpdates()
                }
            }
        } else { // Temporary fix
            delegate.appendToItems(itemsToAppend: itemsToInsert)
            delegate.removeFromItems(itemsToRemove: itemsToDelete)
            collectionView.reloadWith { [weak self] in
                self?.isUpdating = false
                self?.delegate.didCompleteUpdates()
            }
        }
    }
    
    private func getIndexPathsFor(items: [T]) -> [IndexPath] {
        let allItems: [T] = delegate.getCurrentItems()
        return items.compactMap({ (item) -> IndexPath? in
            guard let row = allItems.index(of: item) else { return nil }
            return IndexPath(row: row, section: 0)
        }).sorted(by: { $0.row < $1.row })
    }
    
    private func drawFrom(pool: inout [T]) -> [T] {
        let drawnItems = pool
        pool = []
        return drawnItems
    }
}
