//
//  SearchViewController.swift
//  SampleWeatherFramework
//
//  Created by Private Siejkowski on 07/04/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation
import UIKit

final public class SearchViewController: UISearchContainerViewController {
    
    private let tableView = UITableView()
    
    override public func loadView() {
        view = tableView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .green
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
    }
    
}
