//
//  MADLaunchViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import TIFNetwork
import EasyPeasy
import RxSwift

class MADLaunchViewController: MADBaseViewController {
    
    var appInit: MADAppInit?
    var didGetAppInit: Bool = false
    var didInitialAnimation: Bool = false
    
    override func setup() {
        view.backgroundColor = UIColor.MAD.offWhite
        
        let startupView = MADStartupOverlay()
        view.addSubview(startupView)
        startupView.easy.layout([Edges()])
        startupView.animateToAdjustedTint { [weak self] (completed) in
            self?.didInitialAnimation = true
            self?.proceedIfReady()
        }
        getAppInit()
    }
    
    func getAppInit() {
        MADSimpleAPIWrapper.shared.getAppInit { [weak self] (appInit) in
            guard let self = self else { return }
            self.appInit = appInit
            self.didGetAppInit = true
            self.proceedIfReady()
        }
    }
    
    func proceedIfReady() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.didGetAppInit, self.didInitialAnimation else { return }
            let tabBarController = MADTabBarController(appInit: self.appInit)
            self.present(tabBarController, animated: false)
        }
    }
}
