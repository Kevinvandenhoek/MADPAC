//
//  CustomTopBarPage.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

protocol TopBarPage: AnyObject {
    var topView: MADTopView { get }
    var scrollView: UIScrollView { get }
    var topBarPageDelegate: MADTopBarPageDelegate? { get set }
    var vc: UIViewController { get }
}

protocol MADTopBarPageDelegate: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView, bottomInset: CGFloat, topInset: CGFloat)
    func expand()
    func collapse()
}
