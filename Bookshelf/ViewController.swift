//
//  ViewController.swift
//  Bookshelf
//
//  Created by Brennan Stehling on 3/27/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import UIKit
import CoreData
import BookshelfDataStore

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bookStore: BookStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bookStore.fetchedResultsController.delegate = self
        do {
            try bookStore.fetchedResultsController.performFetch()
        }
        catch {
            debugPrint("Failure fetching books. 😮")
        }
        prepareBooks()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController {
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell) {
                let book = bookStore.fetchedResultsController.object(at: indexPath)
                vc.book = book
            }
            else {
                vc.book = nil
            }
        }
    }

    @IBAction func returnHome(segue: UIStoryboardSegue) {
        debugPrint("Returned Home!")
    }

    fileprivate func prepareBooks() {
        if numberOfBooks == 0 {
            let books = [
                [
                    "bookId": UUID().uuidString,
                    "title": "Blink",
                    "author": "Malcolm Gladwell"
                ],
                [
                    "bookId": UUID().uuidString,
                    "title": "Tribe",
                    "author": "Seth Godin"
                ],
                [
                    "bookId": UUID().uuidString,
                    "title": "The Talent Code",
                    "author": "Daniel Coyle"
                ]
            ]
            books.forEach({
                guard let bookId = $0["bookId"],
                    let title = $0["title"],
                    let author = $0["author"] else {
                    return
                }
                bookStore.createBook(bookId: bookId, title: title, author: author, saveContext: false)
            })
            DataStoreManager.sharedInstance.saveContext()
        }

    }

    fileprivate var numberOfBooks: Int {
        return bookStore.fetchedResultsController.fetchedObjects?.count ?? 0
    }

}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfBooks
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)

        let book = bookStore.fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author

        debugPrint("Preparing cell: \(book.bookId ?? "")")

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            debugPrint("Commit delete")
            let book = bookStore.fetchedResultsController.object(at: indexPath)
            bookStore.deleteBook(book)
        }
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        debugPrint("Will end editing: \(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        debugPrint("Did end editing: \(indexPath?.row ?? 0)")
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        debugPrint("Can perform action?")
        return true
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        debugPrint("Perform Action!")
    }

}

extension ViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        debugPrint("Did change object at row: \(indexPath?.row ?? -1)")

        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                tableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        case .update:
            if let updateIndexPath = indexPath {
                tableView.reloadRows(at: [updateIndexPath], with: .automatic)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
        case .move:
            if let deleteIndexPath = indexPath {
                tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
            if let insertIndexPath = newIndexPath {
                tableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        debugPrint("Section did change: \(sectionInfo.name)")
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        debugPrint("Will change content")
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        debugPrint("Did change content")
        tableView.endUpdates()
    }

}
