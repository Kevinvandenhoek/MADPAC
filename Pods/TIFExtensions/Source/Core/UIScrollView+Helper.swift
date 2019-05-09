//
//  UIScrollView+Helper.swift
//
//  Created by AvdLee on 12/12/14.
//  Copyright (c) 2014 Triple IT. All rights reserved.
//

import Foundation

public enum ScrollDirection {
    case horizontal
    case vertical
}

public extension UIScrollView {
    
    var scrollPercentage:CGFloat {
        get {
            if self.contentSize.width > self.contentSize.height {
                return self.scrollPercentageFor(scrollDirection: .horizontal)
            } else {
                return self.scrollPercentageFor(scrollDirection: .vertical)
            }
        }
        set(newValue) {
            // Kill scroll to stop decelerating and directly set this new value
            self.killScroll()
            
            if self.contentSize.width > self.contentSize.height {
                // Horizontal scrolling
                self.setContentOffset(CGPoint(x: (self.contentSize.width - self.frame.size.width) * newValue, y: self.contentOffset.y), animated: false)
            } else {
                // Vertical scrolling
                self.setContentOffset(CGPoint(x: self.contentOffset.x, y: (self.contentSize.height - self.frame.size.height) * newValue), animated: false)
            }
        }
    }
    
    func scrollPercentageFor(scrollDirection:ScrollDirection) -> CGFloat {
        if scrollDirection == .horizontal {
            // Horizontal scrolling
            return self.contentOffset.x/(self.contentSize.width - self.frame.size.width)*100
        } else {
            // Vertical scrolling
            return ceil((self.contentOffset.y/(self.contentSize.height-self.height))*100)
        }
    }
    
    var contentInsetScrollPercentage:CGFloat {
        get {
            return ((self.contentOffset.y / -self.contentInset.top)*100)/100
        }
    }
    
    var currentPage:CGFloat {
        return (self.contentOffset.x + (0.5 * self.width)) / self.width
        
    }
    
    var isScrolledToTop:Bool {
        return self.contentOffset.y == -self.contentInset.top
    }
    
    var numberOfPages:Int {
        return Int(round(self.contentSize.width / self.width))
    }
    
    func scrollToTop(animated: Bool = false) {
        self.setContentOffset(CGPoint(x: 0, y: -self.contentInset.top), animated: animated)
    }
    
    func killScroll() {
        self.isScrollEnabled = false;
        self.isScrollEnabled = true;
    }
    
    func scrollToPage(_ page: Int, animated: Bool) {
        let offsetX = bounds.width * CGFloat(page)
        setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
}
