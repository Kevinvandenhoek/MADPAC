//
//  NFXListController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS) || os(OSX)
import Foundation
import UIKit

final class NFXListController_iOS: NFXListController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate {
    private var tableView: UITableView = UITableView()
    private var searchController: UISearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "🦊 TIFNetwork"
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.frame = view.frame
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(NFXListCell.self, forCellReuseIdentifier: NSStringFromClass(NFXListCell.self))
        
        if NFX.sharedInstance().selectedGesture == .custom {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: NFX.sharedInstance(), action: #selector(NFX.hide))
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.NFXSettings(), style: .plain, target: self, action: #selector(NFXListController_iOS.settingsButtonPressed))
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NFXListController.reloadTableViewData),
            name: NSNotification.Name(rawValue: "NFXReloadData"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NFXListController_iOS.deactivateSearchController),
            name: NSNotification.Name(rawValue: "NFXDeactivateSearch"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTableViewData()
    }
    
    @objc func settingsButtonPressed() {
        var settingsController: NFXSettingsController_iOS
        settingsController = NFXSettingsController_iOS()
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        updateSearchResultsForSearchControllerWithString(searchController.searchBar.text!)
        reloadTableViewData()
    }
    
    @objc func deactivateSearchController() {
        searchController.isActive = false
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
    override func reloadTableViewData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.setNeedsDisplay()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var detailsController : NFXDetailsController_iOS
        detailsController = NFXDetailsController_iOS()
        var model: NFXHTTPModel
        if (searchController.isActive) {
            model = filteredTableData[(indexPath as NSIndexPath).row]
        } else {
            model = NFXHTTPModelManager.sharedInstance.getModels()[(indexPath as NSIndexPath).row]
        }
        detailsController.selectedModel(model)
        navigationController?.pushViewController(detailsController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}

extension NFXListController_iOS {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredTableData.count : NFXHTTPModelManager.sharedInstance.getModels().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(NFXListCell.self), for: indexPath) as? NFXListCell else {
            return UITableViewCell()
        }

        if (searchController.isActive) {
            if filteredTableData.count > 0 {
                let obj = filteredTableData[(indexPath as NSIndexPath).row]
                cell.configForObject(obj)
            }
        } else if NFXHTTPModelManager.sharedInstance.getModels().count > 0 {
            let obj = NFXHTTPModelManager.sharedInstance.getModels()[indexPath.row]
            cell.configForObject(obj)
        }

        return cell
    }

}
#endif
