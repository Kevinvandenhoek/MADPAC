//
//  MADSearchBar.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 04/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol MADSearchBarNavigationBarDelegate: AnyObject {
    func getClearButton() -> MADButton
    func didTapReturn()
}

class MADSearchBar: MADView {
    
    let textField = UITextField()
    
    weak var navigationBarDelegate: MADSearchBarNavigationBarDelegate?
    
    override func setup() {
        super.setup()
        
        addSubview(textField)
        textField.easy.layout([Height(20), CenterY(), Left(15), Right(35)])
        textField.font = UIFont(fontStyle: .regular, size: 14)
        textField.addTarget(self, action: #selector(didEdit), for: UIControlEvents.editingChanged)
        textField.delegate = self
        textField.returnKeyType = .go
        
        updateColors()
    }
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = height / 2
        }
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = height / 2
    }
    
    @objc func didEdit() {
        if textField.text == nil || textField.text == "" {
            navigationBarDelegate?.getClearButton().alpha = 0
        } else {
            navigationBarDelegate?.getClearButton().alpha = 1
        }
    }
}

extension MADSearchBar: ColorUpdatable {
    func updateColors() {
        backgroundColor = (UserPreferences.darkMode ? UIColor.white : UIColor.black).withAlphaComponent(0.05)
        textField.textColor = UIColor.MAD.UIElements.secondaryText
        textField.keyboardAppearance = UserPreferences.darkMode ? .dark : .light
        let attributedString = NSAttributedString.init(string: "Search", attributes: [NSAttributedStringKey.foregroundColor: UIColor.MAD.UIElements.tertiaryText])
        textField.attributedPlaceholder = attributedString
        textField.tintColor = UIColor.MAD.hotPink
    }
}

extension MADSearchBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationBarDelegate?.didTapReturn()
        return true
    }
}
