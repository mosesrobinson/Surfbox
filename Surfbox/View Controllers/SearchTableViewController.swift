//
//  SearchTableViewController.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/12/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }

        vodController.searchForVOD(with: searchTerm) { (error) in
            guard error == nil else { return }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                searchBar.text = ""
            }
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vodController.searchedVODs.count
    }

    let reuseIdentifier = "VODCell"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VODTableViewCell

        let vod = vodController.searchedVODs[indexPath.row]
        cell.vod = vod

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVODDetail" {
            guard let destination = segue.destination as? SearchDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let vod = vodController.searchedVODs[indexPath.row]
            
            destination.vodController = vodController
            destination.vod = vod
        }
    }
    

    var vodController = VODController()
    
    let searchController = UISearchController(searchResultsController: nil)
    
}
