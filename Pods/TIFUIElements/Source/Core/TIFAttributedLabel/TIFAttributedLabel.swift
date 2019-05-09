//
//  TIFAttributedLabel.swift
//  Videoland
//
//  Created by AvdLee on 11/12/14.
//  Copyright (c) 2014 Triple IT. All rights reserved.
//

import UIKit

@objc public protocol TIFAttributedLabelDelegate {
    func didTapAttributedLabel(_ attributedLabel:TIFAttributedLabel)
}

@IBDesignable open class TIFAttributedLabel: ALLocalizableLabel {

    // MARK: Public properties
    @IBInspectable open var spacingBetweenLines: CGFloat = 13.0 {
        didSet {
            updateText(text)
        }
    }
    
    @IBInspectable open var isLink:Bool = false {
        didSet {
            updateText(text)
            updateTapGesture()
        }
    }
    @IBInspectable open var touchMargin:CGFloat = 20.0
    
    @IBOutlet weak open var delegate:TIFAttributedLabelDelegate?
    
    // MARK: Private properties
    private var tapGesture:UITapGestureRecognizer?
    
    override open var text:String? {
        get {
            return super.text
        }
        set (newValue) {
            updateText(newValue)
        }
    }
    
    // MARK: Setup
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        updateText(text)
    }
    
    private func updateText(_ text: String?){
        let attrString = NSMutableAttributedString(string: text ?? "", attributes: attributes())
        attributedText = attrString
    }
    
    private func attributes() -> [NSAttributedStringKey : AnyObject] {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacingBetweenLines
        style.alignment = textAlignment
        var attributes = [
            NSAttributedStringKey.paragraphStyle : style,
            NSAttributedStringKey.font : font
        ] as [NSAttributedStringKey : Any]
        
        if isLink {
            attributes[NSAttributedStringKey.underlineStyle] = NSNumber(value: 1)
        }
        
        return attributes as [NSAttributedStringKey : AnyObject]
    }
    
    // MARK: Underlines
    /// Add underline to text
    private func addUnderline(){
        guard let attributedText = self.attributedText else { return }
        
        // Add underline
        let attrString = NSMutableAttributedString(attributedString: attributedText)
        attrString.addAttribute(NSAttributedStringKey.underlineStyle, value: 1.0, range: NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
    
    /// Remove underline from text
    private func removeUnderline(){
        guard let attributedText = self.attributedText else { return }
        
        // Remove underline
        let attrString = NSMutableAttributedString(attributedString: attributedText)
        attrString.addAttribute(NSAttributedStringKey.underlineStyle, value: 0.0, range: NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
    
    // MARK: Interaction
    private func updateTapGesture(){
        if isLink {
            if tapGesture != nil { return } // Already initialized
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:)))
            addGestureRecognizer(tapGesture!)
            
            isUserInteractionEnabled = true
        } else if let tapGesture = self.tapGesture {
            removeGestureRecognizer(tapGesture)
            self.tapGesture = nil
            isUserInteractionEnabled = false
        }
    }
    
    // Public method
    @objc func didTapLabel(_ gestureRecognizer:UITapGestureRecognizer){
        delegate?.didTapAttributedLabel(self)
    }
    
    // MARK: Layout overrides
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        guard isLink else { return }
        removeUnderline()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard isLink else { return }
        addUnderline()
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        
        guard isLink else { return }
        addUnderline()
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedArea = (self.bounds).insetBy(dx: isLink ? -touchMargin : 0, dy: isLink ? -touchMargin : 0)
        return extendedArea.contains(point)
    }
}
