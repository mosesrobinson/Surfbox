//
//  WishlistTableViewController.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/15/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit
import CoreData

class WishlistTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpApperance()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    let reuseIdentifier = "WishCell"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! WishTableViewCell
        
        let vod = fetchedResultsController.object(at: indexPath)
        cell.vod = vod
        loadImage(forCell: cell, forItemAt: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let vod = fetchedResultsController.object(at: indexPath)
            vodController.delete(vod: vod)
        }
    }
    
    private func setUpApperance() {
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "Background"))
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: WishTableViewCell, forItemAt indexPath: IndexPath) {
        
        let vod = fetchedResultsController.object(at: indexPath)
        
        if let image = cache.value(for: vod.id) {
            
            cell.posterView?.image = image
        } else {
            
            let fetchSmallPhotoOperation = FetchWithCoreDataPhotoOperation(vod: vod)
            
            let cacheOperation = BlockOperation {
                guard let image = fetchSmallPhotoOperation.image else { return }
                
                self.cache.cache(value: image, for: vod.id)
            }
            
            let cellReusedOperation = BlockOperation {
                guard let image = fetchSmallPhotoOperation.image else { return }
                
                if self.tableView.indexPath(for: cell) != indexPath {
                    return
                }
                
                cell.posterView?.image = image
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "ShowFromWish" {
//            guard let destination = segue.destination as? SearchDetailViewController,
//                let indexPath = tableView.indexPathForSelectedRow else { return }
//            let vod = fetchedResultsController.object(at: indexPath)
//
//            destination.vodController = vodController
//            destination.vodID = Int(vod.id)
//        }
//
//    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .none)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.insertRows(at: [newIndexPath], with: .none)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    // MARK: - Properties
    
    private var storedFetchedOperations: [Int64 : FetchWithCoreDataPhotoOperation] = [:]
    
    private let photoFetchQueue = OperationQueue()
    
    private var cache: Cache<Int64, UIImage> = Cache()
    
    let vodController = VODController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<VOD> = {
        
        let fetchRequest: NSFetchRequest<VOD> = VOD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        try! frc.performFetch()
        
        return frc
    }()
}
