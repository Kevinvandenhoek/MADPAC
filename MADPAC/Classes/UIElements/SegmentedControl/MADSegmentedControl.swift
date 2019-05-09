//
//  MADSegmentedControl.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol MADSegmentedControlDelegate: AnyObject {
    func didSelect(index: Int)
}

class MADSegmentedControl: MADView {
    
    enum Style {
        case normal
    }
    
    // Views
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    }()
    private let selectorView = MADRoundView()
    private let bottomSeparatorView = MADView()
    
    // Delegate
    weak var delegate: MADSegmentedControlDelegate?
    
    // Public styling properties
    var cellLabelMargin: CGFloat = 10 { didSet { collectionView.reloadData() } }
    var cellSpacing: CGFloat = 0 { didSet { collectionView.reloadData() } }
    var separatorThickness: CGFloat = 2
    var selectorColor: UIColor = UIColor.black.withAlphaComponent(0.05) {
        didSet {
            selectorView.backgroundColor = selectorColor
        }
    }
    var isAnimated: Bool = true
    var sideInset: CGFloat? { didSet { collectionView.reloadData() } }
    var cellWidth: CGFloat? { didSet { collectionView.reloadData() } }
    var scrollingEnabled: Bool = true { didSet { collectionView.reloadData() } }
    var bottomSeparatorColor: UIColor? {
        didSet {
            bottomSeparatorView.backgroundColor = bottomSeparatorColor ?? UIColor.clear
        }
    }
    var style: Style = .normal { didSet { updateStyle() } }
    
    // Privaty properties
    private var items: [String] = []
    private var selectedIndex: Int?
    private var didInitialAnimation: Bool = false
    
    public var selectedItem: String? { return items[safe: selectedIndex ?? -1] }
    
    // Private styling properties
    private var cellFont: UIFont = UIFont.MAD.avenirMedium(size: 14)
    private var cellFontHighlighted: UIFont?
    private var cellFontSelected: UIFont?
    private var cellBackgroundColor: UIColor = UIColor.black
    private var cellBackgroundColorHighlighted: UIColor?
    private var cellBackgroundColorSelected: UIColor?
    private var cellTintColor: UIColor = UIColor.white
    private var cellTintColorHighlighted: UIColor?
    private var cellTintColorSelected: UIColor?
    
    override func setup() {
        super.setup()
        
        addSubview(collectionView)
        collectionView.easy.layout([Edges()])
        collectionView.register(MADSegmentedControlCollectionViewCell.self, forCellWithReuseIdentifier: MADSegmentedControlCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        
        // Add a selector
        collectionView.addSubview(selectorView)
        selectorView.frame = CGRect.zero
        selectorView.layer.zPosition = -2
        selectorView.backgroundColor = selectorColor
        
        // Add a bottom separator, default invisible
        addSubview(bottomSeparatorView)
        bottomSeparatorView.backgroundColor = bottomSeparatorColor ?? .clear
        bottomSeparatorView.layer.zPosition = -1
        bottomSeparatorView.easy.layout([Left(), Bottom(), Right(), Height(1)])
        
        // Update for the default style
        updateStyle()
    }
    
    func titleFor(indexPath: IndexPath) -> String? {
        return items[safe: indexPath.item]
    }
    
    func itemCount() -> Int {
        return items.count
    }
    
    func reloadData(with completion: (() -> Void)? = nil) {
        if let completion = completion {
            collectionView.reloadWith(completion: completion)
        } else {
            collectionView.reloadData()
        }
    }
}

// View updating
extension MADSegmentedControl {
    func setup(with items: [String]?, startIndex: Int = 0) {
        guard let items = items else { return }
        self.items = items
        self.selectedIndex = startIndex
        collectionView.reloadWith { [weak self] in
            guard let `self` = self, !self.didInitialAnimation else { return }
            self.didInitialAnimation = true
            self.collectionView.selectItem(at: IndexPath(row: startIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            self.fadeIn(self.selectorView)
        }
    }
    
    func select(index: Int, animated: Bool = false) {
        guard index < itemCount() else { return }
        collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: animated, scrollPosition: .centeredHorizontally)
    }
    
    func setFont(_ font: UIFont, state: MADSegmentedControlCollectionViewCell.State?) {
        guard let state = state else { // Use same value for all states
            cellFont = font
            cellFontHighlighted = nil
            cellFontSelected = nil
            return
        }
        switch state {
        case .normal:
            cellFont = font
        case .highlighted:
            cellFontHighlighted = font
        case.selected:
            cellFontSelected = font
        }
    }
    
    func setTintColor(_ color: UIColor, state: MADSegmentedControlCollectionViewCell.State?) {
        guard let state = state else { // Use same value for all states
            cellTintColor = color
            cellTintColorHighlighted = nil
            cellTintColorSelected = nil
            return
        }
        switch state {
        case .normal:
            cellTintColor = color
        case .highlighted:
            cellTintColorHighlighted = color
        case.selected:
            cellTintColorSelected = color
        }
    }
    
    func setCellBackgroundColor(_ color: UIColor, state: MADSegmentedControlCollectionViewCell.State?) {
        guard let state = state else { // Use same value for all states
            cellBackgroundColor = color
            cellBackgroundColorHighlighted = nil
            cellBackgroundColorSelected = nil
            return
        }
        switch state {
        case .normal:
            cellBackgroundColor = color
        case .highlighted:
            cellBackgroundColorHighlighted = color
        case.selected:
            cellBackgroundColorSelected = color
        }
    }
    
    private func updateStyle() {
        switch style {
        case .normal:
            setFont(UIFont.MAD.avenirMedium(size: 14), state: nil)
            setTintColor(UIColor.MAD.UIElements.secondaryText, state: .normal)
            setTintColor(UIColor.MAD.UIElements.secondaryText.withAlphaComponent(0.6), state: .highlighted)
            setTintColor(UIColor.MAD.UIElements.tertiaryText, state: .selected)
            setCellBackgroundColor(.clear, state: nil)
            backgroundColor = UIColor.white
            bottomSeparatorColor = UIColor.MAD.UIElements.tertiaryText
        }
    }
}

extension MADSegmentedControl: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset: CGFloat = sideInset ?? 0
        if let cellWidth = cellWidth, (cellWidth * CGFloat(itemCount())) < self.width {
            let cumulatedCellWidth: CGFloat = CGFloat(itemCount()) * cellWidth
            inset = (collectionView.width - cumulatedCellWidth) / 2
        }
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let text = titleFor(indexPath: indexPath) else { return CGSize.zero }
        var width: CGFloat = 0
        if scrollingEnabled {
            width = cellWidth ?? cellFont.getWidthFor(text: text) + (2 * cellLabelMargin)
        } else {
            if let cellWidth = cellWidth {
                width = cellWidth
            } else {
                let cellCount: CGFloat = CGFloat(itemCount())
                let gapCount: CGFloat = CGFloat(cellCount - 1)
                let cumulativeSpacing: CGFloat = gapCount * cellSpacing
                let cumulativeInset: CGFloat = (sideInset ?? 0) * 2
                let widthAfterSpacing: CGFloat = self.width - (cumulativeInset + cumulativeSpacing)
                width = widthAfterSpacing / cellCount
            }
        }
        let height: CGFloat = collectionView.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.item
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.didSelect(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !didInitialAnimation else { return }
        fadeIn(cell)
    }
}

extension MADSegmentedControl: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MADSegmentedControlCollectionViewCell.reuseIdentifier, for: indexPath) as? MADSegmentedControlCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setup(with: titleFor(indexPath: indexPath), delegate: self)
        cell.layer.zPosition = 1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount()
    }
}

extension MADSegmentedControl: MADSegmentedControlCollectionViewCellDelegate {
    func getFont(_ state: MADSegmentedControlCollectionViewCell.State) -> UIFont {
        switch state {
        case .normal:
            return cellFont
        case .highlighted:
            return cellFontHighlighted ?? cellFont
        case .selected:
            return cellFontSelected ?? cellFont
        }
    }
    
    func getTintColor(_ state: MADSegmentedControlCollectionViewCell.State) -> UIColor {
        switch state {
        case .normal:
            return cellTintColor
        case .highlighted:
            return cellTintColorHighlighted ?? cellTintColor
        case .selected:
            return cellTintColorSelected ?? cellTintColor
        }
    }
    
    func getCellBackgroundColor(_ state: MADSegmentedControlCollectionViewCell.State) -> UIColor {
        switch state {
        case .normal:
            return cellBackgroundColor
        case .highlighted:
            return cellBackgroundColorHighlighted ?? cellBackgroundColor
        case .selected:
            return cellBackgroundColorSelected ?? cellBackgroundColor
        }
    }
    
    func moveSelector(to frame: CGRect) {
        guard selectorView.frame != CGRect.zero, isAnimated else {
            self.updateSelectorFrame(to: frame)
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            self.updateSelectorFrame(to: frame)
        })
    }
    
    private func updateSelectorFrame(to frame: CGRect) {
        let xPos = frame.minX
        selectorView.frame = CGRect(x: xPos, y: (collectionView.height - separatorThickness) / 2, width: frame.width, height: separatorThickness)
    }
}

// Helper methods
extension MADSegmentedControl {
    func fadeIn(_ view: UIView) {
        view.alpha = 0
        view.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        })
    }
}

extension MADSegmentedControl: ColorUpdatable {
    
    func updateColors() {
        collectionView.visibleCells.compactMap({ $0 as? ColorUpdatable }).forEach({ $0.updateColors() })
    }
}
