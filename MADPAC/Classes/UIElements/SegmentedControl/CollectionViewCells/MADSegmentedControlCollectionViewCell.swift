//
//  MADSegmentedControlCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import TIFExtensions
import EasyPeasy

protocol MADSegmentedControlCollectionViewCellDelegate: AnyObject {
    func getFont(_ state: MADSegmentedControlCollectionViewCell.State) -> UIFont
    func getTintColor(_ state: MADSegmentedControlCollectionViewCell.State) -> UIColor
    func getCellBackgroundColor(_ state: MADSegmentedControlCollectionViewCell.State) -> UIColor
    func moveSelector(to frame: CGRect)
}

final class MADSegmentedControlCollectionViewCell: MADBaseCollectionViewCell {
    
    private let label: UILabel = MADLabel(style: .category)
    
    // Internal properties
    enum State {
        case normal
        case highlighted
        case selected
    }
    private var state: State = .normal
    
    // Delegate
    weak var delegate: MADSegmentedControlCollectionViewCellDelegate?
    
    override func setup() {
        super.setup()
        addSubview(label)
        label.easy.layout([Edges()])
        label.textAlignment = .center
    }
    
    func setup(with title: String?, delegate: MADSegmentedControlCollectionViewCellDelegate) {
        self.delegate = delegate
        label.text = title
        updateRenderState()
    }
    
    private func updateRenderState() {
        guard let delegate = delegate else { return }
        label.font = delegate.getFont(state)
        label.textColor = delegate.getTintColor(state)
        backgroundColor = delegate.getCellBackgroundColor(state)
    }
    
    override var isHighlighted: Bool {
        didSet {
            state = isHighlighted ? .highlighted : (isSelected ? .selected : .normal)
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.updateRenderState()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            state = isSelected ? .selected : (isHighlighted ? .highlighted : .normal)
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.updateRenderState()
            }
            if isSelected {
                delegate?.moveSelector(to: frame)
            }
        }
    }
    
    override func updateColors() {
        super.updateColors()
        updateRenderState()
    }
}
