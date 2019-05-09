//
//  TIFRxPageControl.swift
//  Pods
//
//  Created by Jimmy Arts on 09/05/16.
//
//

import UIKit
import RxSwift
import RxCocoa

open class TIFRxPageControl: UIPageControl {
    
    // MARK: Public properties
    @IBOutlet public weak var scrollView: UIScrollView? {
        didSet {
            setupObservers()
        }
    }
    
    // MARK: Private properties
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        defersCurrentPageDisplay = true
    }
    
    func setupObservers() {
        scrollView?.rx.contentOffset
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (offSet) in
                if let scrollView = self?.scrollView {
                    self?.currentPage = Int(scrollView.currentPage)
                }
                self?.currentPage = 0
            })
            .disposed(by: disposeBag)

        scrollView?.rx.observe(CGSize.self, "contentSize")
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (size) in
                if let _ = self?.scrollView, let size = size {
                    self?.numberOfPages = Int(size.width)
                }
                self?.numberOfPages = 0
            })
            .disposed(by: disposeBag)
        
        rx.controlEvent(.valueChanged)
            .takeUntil(rx.deallocating)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (sender) in
                guard let scrollView = self?.scrollView, let pageControl = self else { return }
                let offset = CGPoint(x: scrollView.frame.size.width * CGFloat(pageControl.currentPage), y: scrollView.contentOffset.y)
                scrollView.setContentOffset(offset, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
