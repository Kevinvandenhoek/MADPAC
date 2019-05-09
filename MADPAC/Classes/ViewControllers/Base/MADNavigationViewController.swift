//
//  MADNavigationViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADNavigationViewController: UINavigationController {
    
    var topBarPage: TopBarPage?
    var topBarOffset: CGFloat = 0
    var topBarLastScrollOffset: CGFloat = 0
    var baseBarHeight: CGFloat = 0
    var titleLabel: MADLabel = MADLabel(style: .navigationTitle)
    
    let backButton = MADButton()
    let searchButton = MADButton()
    let searchClearButton = MADButton()
    let searchBar = MADSearchBar()
    
    let backgroundView = UIVisualEffectView()
    let shadowView = UIImageView()
    var blurEffect: UIVisualEffect { return UIBlurEffect(style: UserPreferences.darkMode ? .dark : .extraLight) }
    weak var popAnimator: PopAnimator?
    
    private var searchWidth: CGFloat { return view.width - 80 }
    
    private var navigationInteractor: MADNavigationInteractor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        searchButton.alpha = rootViewController is SearchEnabledPage ? 1 : 0
        handleBackButton(for: rootViewController, animated: false)
        
        if let tabbedPage = rootViewController as? TabbedPage {
            tabBarItem.title = tabbedPage.tabTitle
            tabBarItem.image = tabbedPage.tabImage
            setNavigationBarTitle(to: tabbedPage.pageTitle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        delegate = self
        baseBarHeight = navigationBar.heightConstraint?.constant ?? navigationBar.frame.height
        navigationBar.barStyle = .blackTranslucent
        navigationBar.backgroundColor = .clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        shadowView.image = #imageLiteral(resourceName: "navigationbar_shadow")
        shadowView.contentMode = .scaleToFill
        
        navigationBar.insertSubview(backgroundView, at: 0)
        backgroundView.easy.layout([Top().to(self.view, .top), Left().to(self.view, .left), Right().to(self.view, .right), Bottom().to(navigationBar, .bottom)])
        
        navigationBar.insertSubview(shadowView, at: 0)
        shadowView.easy.layout(Top().to(backgroundView, .bottom), Left().to(self.view, .left), Right().to(self.view, .right), Height(shadowView.image?.size.height ?? 0))
        
        navigationBar.addSubview(titleLabel)
        titleLabel.easy.layout([Width(200), Height(30), Center()])
        titleLabel.textAlignment = .center
        
        navigationBar.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.easy.layout([Width(40), Height(40), Left(), CenterY()])
        backButton.image = #imageLiteral(resourceName: "icon_backward").withRenderingMode(.alwaysTemplate)
        
        navigationBar.addSubview(searchButton)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        searchButton.image = UIImage(named: "icon_search")?.withRenderingMode(.alwaysTemplate)
        searchButton.easy.layout([Size(50), Right(), CenterY(-2)])
        
        navigationBar.addSubview(searchClearButton)
        searchClearButton.easy.layout([Size(30), Right(10), CenterY()])
        searchClearButton.image = UIImage(named: "icon_search_clear")?.withRenderingMode(.alwaysTemplate)
        searchClearButton.addTarget(self, action: #selector(searchClearTapped), for: .touchUpInside)
        
        navigationBar.insertSubview(searchBar, belowSubview: searchButton)
        searchBar.navigationBarDelegate = self
        showSearchBar(false)
        
        updateColors()
    }
    
    func handleTopPage(for vc: UIViewController?) {
        guard let newTopBarPage = vc as? TopBarPage else {
            topBarPage?.topView.removeFromSuperview()
            topBarPage?.topBarPageDelegate = nil
            topBarOffset = 0
            self.topBarPage = nil
            backgroundView.easy.layout([Bottom().to(navigationBar, .bottom)])
            return
        }
        guard topBarPage?.vc != newTopBarPage.vc else {
            (vc as? TopBarPage)?.topBarPageDelegate = self
            return
        }
        topBarPage?.topView.removeFromSuperview()
        topBarPage?.topBarPageDelegate = nil
        if let topBarPage = vc as? TopBarPage {
            self.topBarPage = topBarPage
            self.topBarPage?.topView.navigationControllerDelegate = self
            view.addSubview(topBarPage.topView)
            topBarOffset = topBarPage.topView.baseHeight - topBarPage.topView.minimumHeight
            topBarPage.topView.easy.layout([Left(), Right(), Height(0), Top().to(navigationBar, .bottom)])
            topBarPage.scrollView.contentInset = UIEdgeInsets(top: topBarPage.topView.baseHeight, left: 0, bottom: 0, right: 0)
            backgroundView.easy.layout([Bottom().to(topBarPage.topView, .bottom)])
            (vc as? TopBarPage)?.topBarPageDelegate = self
            topBarPage.topView.alpha = 0
        } else {
            self.topBarPage = nil
            backgroundView.easy.layout([Bottom().to(navigationBar, .bottom)])
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? (UserPreferences.darkMode ? .lightContent : .default)
    }
    
    @objc func backTapped() {
        self.popViewController(animated: true)
    }
    
    @objc func searchTapped() {
        if let searchVC = topViewController as? MADSearchViewController { // Search logic
            searchVC.fetchForSearchTerm(searchBar.textField.text)
        } else {
            self.pushViewController(MADSearchViewController(), animated: true)
        }
    }
    
    @objc func searchClearTapped() {
        searchBar.textField.text = nil
        searchClearButton.alpha = 0
        if let searchVC = topViewController as? MADSearchViewController { // Search logic
            searchVC.clearContent()
            searchBar.textField.becomeFirstResponder()
        }
    }
}

// View updating
extension MADNavigationViewController {
    
    func setNavigationBarTitle(to text: String?) {
        titleLabel.text = text
    }
    
    func showTitle(_ show: Bool) {
        titleLabel.alpha = show ? 1 : 0
        titleLabel.transform = show
            ? CGAffineTransform.identity
            : CGAffineTransform.identity.translatedBy(x: 0, y: -15)
    }
    
    func updateBackButtonInTransition(for toVC: UIViewController) {
        showBackButton(toVC != self.viewControllers.first)
    }
    
    func handleBackButton(for toVC: UIViewController, animated: Bool) {
        let isHidden = toVC == self.viewControllers.first
        UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
            self?.showBackButton(!isHidden)
        }
    }
    
    private func showBackButton(_ show: Bool) {
        if show {
            backButton.alpha = 1
            backButton.transform = CGAffineTransform.identity
        } else {
            backButton.alpha = 0
            backButton.transform = CGAffineTransform.identity.translatedBy(x: 10, y: 0)
        }
    }
}

extension MADNavigationViewController: MADTopBarPageDelegate {
    
    // TODO: Magic number 84 until i figure out whats causing the delta
    func scrollViewDidScroll(_ scrollView: UIScrollView, bottomInset: CGFloat, topInset: CGFloat) {
        guard let topBarPage = topBarPage else { return }
        let topView = topBarPage.topView
        let offset = -(scrollView.contentOffset.y + topInset)
        let delta = offset - topBarLastScrollOffset
        let minHeight = topView.minimumHeight
        if offset >= 0 {
            topBarOffset -= abs(delta)
        } else {
            topBarOffset -= delta
        }
        
        // Avoid bottom bounce back capturing
        var overshoot = abs(scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.frame.size.height)
        if topViewController is MADVideoTabDetailViewController {
            // We dont need the compensation here
            //print("Not compensating overshoot: \(overshoot)")
        } else {
            overshoot -= 84
            //print("compensated overshoot for \(topBarPage.vc)")
        }

        // Offset the top bar, but only if we aren't bouncing back
        guard overshoot < 0 else { return }
        topBarOffset = min(max(0, (topBarOffset)), (topView.baseHeight - minHeight))
        topView.easy.layout([Height(topView.baseHeight - topBarOffset)])
        let lerpAmount: CGFloat = topBarOffset / (topView.baseHeight - minHeight)
        topView.displayOffset(lerpAmount: max(min(lerpAmount, 1), 0))
        topBarLastScrollOffset = offset
    }
    
    func expand() {
        guard let topView = self.topBarPage?.topView else { return }
        self.topBarOffset = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            topView.easy.layout([Height(topView.baseHeight - self.topBarOffset)])
            self.view.layoutIfNeeded()
        })
    }
    
    func collapse() {
        guard let topView = self.topBarPage?.topView else { return }
        self.topBarOffset = topView.baseHeight - topView.minimumHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            topView.easy.layout([Height(topView.baseHeight - self.topBarOffset)])
            self.view.layoutIfNeeded()
        })
    }
}

extension MADNavigationViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let receivingView = toVC as? NavigationTransitioningView,
            let givingView = fromVC as? NavigationTransitioningView,
            let targetRect = receivingView.getTargetRect(),
            let originRect = givingView.getTargetRect(),
            let transitioningView = givingView.getTransitioningView(),
            receivingView.allows(view: transitioningView)
        else {
            if toVC is MADSearchViewController || fromVC is MADSearchViewController {
                (toVC as? MADSearchViewController)?.delegate = self
                return MADSearchNavigationAnimator(duration: UserPreferences.slowAnimations ? 1.5 : 0.4, isPresenting: operation == .push, navigationController: self)
            } else if toVC is MADVideoTabDetailViewController || fromVC is MADVideoTabDetailViewController {
                return videoTabAnimator(navigationController, for: toVC, fromVC: fromVC, operation: operation)
            } else {
                return basicAnimator(navigationController, for: toVC, fromVC: fromVC, operation: operation)
            }
        }
        let distance: CGFloat = abs(targetRect.midY - originRect.midY)
        let relativeDistance: CGFloat = distance / UIScreen.main.bounds.height
        let extraTravelTime: CGFloat = relativeDistance * 0.2
        let duration: CGFloat = UserPreferences.slowAnimations ? 1.5 : 0.4 + extraTravelTime
        let animator = MADTransitioningViewNavigationAnimator(duration: duration, isPresenting: operation == .push, originRect: originRect, targetRect: targetRect, transitioningView: transitioningView, givingView: givingView, receivingView: receivingView, navigationController: self)
        self.popAnimator = animator
        if operation == .push {
            self.navigationInteractor = MADNavigationInteractor(attachTo: toVC)
        }
        return animator
    }
    
    private func videoTabAnimator(_ navigationController: UINavigationController, for toVC: UIViewController, fromVC: UIViewController, operation: UINavigationControllerOperation) -> UIViewControllerAnimatedTransitioning? {
        if let videoVC = fromVC as? MADVideoViewController {
            let duration: CGFloat = UserPreferences.slowAnimations ? 1.5 : 0.4
            self.navigationInteractor = MADNavigationInteractor(attachTo: toVC)
            let animator = MADVideoTabNavigationAnimator(duration: duration, isPresenting: operation == .push, videoTopView: videoVC.videoTopView, navigationController: self)
            self.popAnimator = animator
            return animator
        } else if let videoVC = toVC as? MADVideoViewController {
            let duration: CGFloat = UserPreferences.slowAnimations ? 1.5 : 0.4
            let animator = MADVideoTabNavigationAnimator(duration: duration, isPresenting: operation == .push, videoTopView: videoVC.videoTopView, navigationController: self)
            self.popAnimator = animator
            return animator
        } else {
            return nil
        }
    }
    
    private func basicAnimator(_ navigationController: UINavigationController, for toVC: UIViewController, fromVC: UIViewController, operation: UINavigationControllerOperation) -> UIViewControllerAnimatedTransitioning? {
        let duration: CGFloat = UserPreferences.slowAnimations ? 1.5 : 0.4
        let animator = MADBasicNavigationAnimator(duration: duration, isPresenting: operation == .push, navigationController: self)
        self.popAnimator = animator
        return animator
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactor = navigationInteractor else { return nil }
        if interactor.transitionInProgress {
            popAnimator?.isPop = true
            return navigationInteractor
        } else {
            popAnimator?.isPop = false
            return nil
        }
    }
}

extension MADNavigationViewController: MADTopViewNavigationControllerDelegate {
    
    func setTopBarAlpha(to alpha: CGFloat) {
        self.topBarPage?.topView.alpha = alpha
    }
    
    func updateTopBarOffset(to offset: CGFloat) {
        if let topView = self.topBarPage?.topView {
            self.topBarOffset = offset
            topView.easy.layout([Height(topView.baseHeight - topBarOffset)])
            let minHeight = topView.minimumHeight
            let lerpAmount: CGFloat = topBarOffset / (topView.baseHeight - minHeight)
            topView.displayOffset(lerpAmount: max(min(lerpAmount, 1), 0))
            topView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    func hideTopBar() {
        if let topView = self.topBarPage?.topView {
            self.topBarOffset = topView.baseHeight
            topView.easy.layout([Height(0)])
            let minHeight = topView.minimumHeight
            let lerpAmount: CGFloat = topBarOffset / (topView.baseHeight - minHeight)
            topView.displayOffset(lerpAmount: max(min(lerpAmount, 1), 0))
            topView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    func updateSearchVisiblity(for toVC: UIViewController) {
        if toVC is MADSearchViewController {
            searchButton.alpha = 1
            searchButton.tintColor = UIColor.MAD.UIElements.primaryTint
            searchBar.alpha = 1
        } else {
            let hasSearch = toVC is SearchEnabledPage
            searchButton.alpha = hasSearch ? 1 : 0
            searchButton.tintColor = UIColor.MAD.UIElements.secondaryText
            searchBar.alpha = 0
        }
    }
    
    func showSearchBar(_ show: Bool) {
        searchBar.easy.layout([Width(show ? searchWidth : 30), Height(30), CenterX(), CenterY()])
        searchBar.alpha = show ? 1 : 0
        searchButton.transform = show
            ? CGAffineTransform.identity.translatedBy(x: -30, y: 1)
            : CGAffineTransform.identity
        searchButton.imageView?.transform = show
            ? CGAffineTransform.identity.rotated(by: 0.5 * CGFloat.pi)
            : CGAffineTransform.identity
        if show {
            searchBar.textField.text = nil
            searchBar.textField.becomeFirstResponder()
        } else {
            searchBar.textField.resignFirstResponder()
            searchClearButton.alpha = 0
        }
        view.layoutIfNeeded()
    }
}

extension MADNavigationViewController: ColorUpdatable {
    
    func updateColors() {
        titleLabel.updateStyle()
        backgroundView.effect = blurEffect
        backButton.tintColor = UIColor.MAD.UIElements.secondaryText
        searchClearButton.tintColor = UIColor.MAD.UIElements.secondaryText
        searchButton.tintColor = (topViewController is MADSearchViewController) ? UIColor.MAD.UIElements.primaryTint : UIColor.MAD.UIElements.secondaryText
        navigationBar.tintColor = UIColor.MAD.UIElements.primaryTint
        view.backgroundColor = UIColor.MAD.UIElements.pageBackground
        searchBar.updateColors()
        
        (topBarPage?.topView as? ColorUpdatable)?.updateColors()
    }
}

extension MADNavigationViewController: MADSearchBarNavigationBarDelegate {
    
    func getClearButton() -> MADButton {
        return searchClearButton
    }
    
    func didTapReturn() {
        searchTapped()
    }
}

extension MADNavigationViewController: MADSearchViewControllerDelegate {
    
    func getSearchBar() -> MADSearchBar {
        return searchBar
    }
}
