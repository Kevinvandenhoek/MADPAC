//
//  ViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import RxSwift

class MADBaseViewController: UIViewController, NavigationTransitioningView, ColorUpdatable {
    
    var isTransitioning: Bool = false
    var hidesNavigationBarTitle: Bool { return false }
    private(set) var isVisible: Bool = false
    
    func allows(view: UIView) -> Bool {
        return false
    }
    
    func getTransitioningView<T>() -> T? where T : UIView {
        return nil
    }
    
    func getTargetRect() -> CGRect? {
        return nil
    }
    
    func receive(transitionedView: UIView) {
        assertionFailure("'receive' not implemented (NavigationTransitioningView)")
    }
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        isTransitioning = true
        view.backgroundColor = presenting ? UIColor.clear : UIColor.MAD.UIElements.pageBackground
    }
    
    func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        view.backgroundColor = presenting ? UIColor.MAD.UIElements.pageBackground: UIColor.clear
    }
    
    func endTransition(presenting: Bool, completed: Bool) {
        view.backgroundColor = UIColor.MAD.UIElements.pageBackground
        isTransitioning = false
    }
    
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.initialize()
    }
    
    func initialize() {
        // Hide back button the 'normal' way fucks with the pop gesture for god knows what reason (popping back freezes the app)
        let transparentView = UIView()
        transparentView.isUserInteractionEnabled = false
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: transparentView), animated: false)
    }
    
    var preferredNavigationBarAlpha: CGFloat { return 1 }
    var preferredNavigationBarTintColor: UIColor { return UIColor.MAD.UIElements.primaryTint }
    
    override func viewDidLoad() {
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UserPreferences.darkMode ? .lightContent : .default
    }
    
    func setup() {
        updateColors()
    }
    
    func updateColors() {
        view.backgroundColor = UIColor.MAD.UIElements.pageBackground
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible = false
    }
}

