//
//  TabbedPage.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

protocol TabbedPage {
    var pageTitle: String { get }
    var tabTitle: String? { get }
    var tabImage: UIImage { get }
    
    func becameSelectedTab()
    func becameDeselectedTab()
}

extension TabbedPage {
    func becameSelectedTab() { }
    func becameDeselectedTab() { }
}
