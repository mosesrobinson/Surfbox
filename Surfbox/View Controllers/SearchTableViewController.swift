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
        
        setUpApperance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpSearchController()
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
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = AppearanceHelper.paperWhite
    }
    
    private func setUpApperance() {
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "Background"))
    }
    
    override func didReceiveMemoryWarning() {
        print("You are low on memory")
        cache.clear()
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
        loadImage(forCell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: VODTableViewCell, forItemAt indexPath: IndexPath) {
        
        let vod = vodController.searchedVODs[indexPath.row]
        
        if let image = cache.value(for: vod.id) {
            
            cell.imageView?.image = image
            cell.imageView?.contentMode = .scaleAspectFit
            return
        } else {
            
            let fetchSmallPhotoOperation = FetchSmallPhotoOperation(vod: vod)
            
            let cacheOperation = BlockOperation {
                guard let image = fetchSmallPhotoOperation.image else { return }
                
                self.cache.cache(value: image, for: vod.id)
            }
            
            let cellReusedOperation = BlockOperation {
                guard let image = fetchSmallPhotoOperation.image else { return }
                
                if self.tableView.indexPath(for: cell) != indexPath {
                    return
                }
                
                cell.imageView?.image = image
                cell.imageView?.contentMode = .scaleAspectFit
                self.tableView.reloadData()
            }
            
            cacheOperation.addDependency(fetchSmallPhotoOperation)
            cellReusedOperation.addDependency(fetchSmallPhotoOperation)
            
            photoFetchQueue.addOperations([fetchSmallPhotoOperation, cacheOperation], waitUntilFinished: false)
            OperationQueue.main.addOperation(cellReusedOperation)
            
            storedFetchedOperations[vod.id] = fetchSmallPhotoOperation
        }
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVODDetail" {
            guard let destination = segue.destination as? SearchDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let vod = vodController.searchedVODs[indexPath.row]
            
            destination.vodController = vodController
            destination.vod = vod
            destination.vodID = vod.id
        }
        
        
        // need to create segue for showing favorites. Remove tab layout of application. 
    }
    
    //MARK: - Properties
    
    private var storedFetchedOperations: [Int : FetchSmallPhotoOperation] = [:]
    
    private let photoFetchQueue = OperationQueue()
    
    private var cache: Cache<Int, UIImage> = Cache()

    var vodController = VODController()
    
    let searchController = UISearchController(searchResultsController: nil)
    
}
