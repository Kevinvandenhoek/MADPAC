//
//  SeekView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 02/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADSeekView: MADView {
    
    let circleView = MADView()
    let backwardSeekLabel = MADLabel(style: .seek)
    let forwardSeekLabel = MADLabel(style: .seek)
    
    let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    private var underlayLocation: UnderlayLocation = .hidden
    enum UnderlayLocation {
        case hidden
        case left
        case right
    }
    
    override func setup() {
        super.setup()
        
        addSubview(circleView)
        circleView.easy.layout([Size(height * 3), CenterY(), CenterX()])
        circleView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        
        addSubview(backwardSeekLabel)
        backwardSeekLabel.easy.layout([CenterX(-(width / 2) - 140), CenterY()])
        backwardSeekLabel.layer.shadowColor = UIColor.black.cgColor
        backwardSeekLabel.layer.shadowOffset = CGSize.zero
        backwardSeekLabel.layer.shadowOpacity = 0.4
        
        addSubview(forwardSeekLabel)
        forwardSeekLabel.easy.layout([CenterX((width / 2) + 140), CenterY()])
        forwardSeekLabel.layer.shadowColor = UIColor.black.cgColor
        forwardSeekLabel.layer.shadowOffset = CGSize.zero
        forwardSeekLabel.layer.shadowOpacity = 0.4
        
        isUserInteractionEnabled = false
        reset()
        self.circleView.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.easy.layout([Size(height * 3)])
        circleView.layer.cornerRadius = height * 1.5
    }
    
    override var frame: CGRect {
        didSet {
            circleView.easy.layout([Size(height * 3)])
            circleView.layer.cornerRadius = height * 1.5
        }
    }
    
    private func moveSeekUnderlay(to underlayLocation: UnderlayLocation) {
        guard self.underlayLocation != underlayLocation else { return }
        self.underlayLocation = underlayLocation
        
        let offset = ((height * 3) / 2) + 100
        switch underlayLocation {
        case .hidden:
            self.circleView.alpha = 0
        case .left:
            self.circleView.alpha = 1
            self.circleView.transform = CGAffineTransform.identity.translatedBy(x: -offset, y: 0)
        case .right:
            self.circleView.alpha = 1
            self.circleView.transform = CGAffineTransform.identity.translatedBy(x: offset, y: 0)
        }
    }
    
    private func updateLabelsFor(seconds: Double) {
        if seconds > 0 {
            let text = formatter.string(from: TimeInterval(seconds))
            forwardSeekLabel.text = text
            forwardSeekLabel.alpha = 1
            backwardSeekLabel.text = nil
            backwardSeekLabel.alpha = 0
        } else {
            let text = formatter.string(from: TimeInterval(-seconds))
            backwardSeekLabel.text = text
            backwardSeekLabel.alpha = 1
            forwardSeekLabel.text = nil
            forwardSeekLabel.alpha = 0
        }
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.reset()
        })
    }
    
    private func reset() {
        moveSeekUnderlay(to: .hidden)
        backwardSeekLabel.alpha = 0
        backwardSeekLabel.text = nil
        forwardSeekLabel.alpha = 0
        forwardSeekLabel.text = nil
    }
    
    func displaySeekDelta(seconds: Double) {
        if self.underlayLocation == .hidden {
            moveUnderlayForAnimatingIn(right: seconds > 0)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            self.updateLabelsFor(seconds: seconds)
            if seconds > 0 {
                self.moveSeekUnderlay(to: .right)
            } else {
                self.moveSeekUnderlay(to: .left)
            }
        })
    }
    
    private func moveUnderlayForAnimatingIn(right: Bool) {
        let offset = ((height * 3) / 2) + 100
        if right {
            circleView.transform = CGAffineTransform.identity.translatedBy(x: offset, y: 0)
        } else {
            circleView.transform = CGAffineTransform.identity.translatedBy(x: -offset, y: 0)
        }
        circleView.transform = circleView.transform.scaledBy(x: 1.2, y: 1.2)
    }
}
