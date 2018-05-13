//
//  GlossaryViewController.swift
//  MultiLanguageGlossary
//
//  Created by Artem Misesin on 4/14/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit
import RealmSwift

class GlossaryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchString = ""
    
    let realm = try! Realm()
    let categories = try! Realm().objects(Domain.self).sorted(byKeyPath: "name")
    lazy var filteredCategories = try! Realm().objects(Domain.self).filter("name CONTAINS '\(self.searchString)'").sorted(byKeyPath: "name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.navigationController?.navigationBar.prefersLargeTitles = true
        setupSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: false)
        }
        tableView.reloadData()
    }
    
    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Enter a category"
        self.navigationItem.searchController = searchController
    }
    
}

extension GlossaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredCategories.count
        } else {
            return categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "glossaryWordCell", for: indexPath)
        if isSearching {
            print(filteredCategories[indexPath.row].name)
            cell.textLabel?.text = filteredCategories[indexPath.row].name
            cell.detailTextLabel?.text = String(describing: filteredCategories[indexPath.row].definitions.count)
        } else {
            cell.textLabel?.text = categories[indexPath.row].name
            cell.detailTextLabel?.text = String(describing: categories[indexPath.row].definitions.count)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DomainDefinitionsVC") as? DomainDefinitionsViewController {
            if isSearching {
                vc.domainName = filteredCategories[indexPath.row].name
            } else {
                vc.domainName = categories[indexPath.row].name
            }
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension GlossaryViewController: UISearchResultsUpdating {
    
    var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchString = searchController.searchBar.text ?? ""
        filteredCategories = try! Realm().objects(Domain.self).filter("name CONTAINS '\(searchString)'").sorted(byKeyPath: "name")
        tableView.reloadData()
    }
    
}
