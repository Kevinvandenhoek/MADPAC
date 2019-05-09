//
//  MADWebView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import WebKit

protocol MADWebViewDelegate: AnyObject {
    func didChangeContentSize(to size: CGSize)
}

class MADWebView: WKWebView {
    
    weak var delegate: MADWebViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        setup()
    }
    
    private func setup() {
        self.scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        self.scrollView.layer.masksToBounds = false
        self.scrollView.clipsToBounds = false
    }
    
    deinit {
        self.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentSize" else { return }
        let contentSize = scrollView.contentSize
        if contentSize.width > frame.width {
            scrollView.contentSize = CGSize(width: frame.width, height: contentSize.height)
        }
        delegate?.didChangeContentSize(to: contentSize)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !clipsToBounds && !isHidden && alpha > 0 {
            for subview in subviews.reversed() {
                let subpoint = convert(point, to: subview)
                let result = subview.hitTest(subpoint, with: event)
                if let result = result {
                    return result
                }
            }
        }
        return scrollView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard self.isUserInteractionEnabled && self.alpha > 0 && !self.isHidden else {
            return false
        }
        for subview in subviews {
            let convertedPoint = self.convert(point, to: subview)
            guard subview.alpha > 0 && !subview.isHidden && subview.isUserInteractionEnabled else {
                continue
            }
            if subview.point(inside: convertedPoint, with: event) {
                return true
            }
        }
        return true
    }
}
