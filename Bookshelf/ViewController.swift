//
//  ViewController.swift
//  Bookshelf
//
//  Created by Brennan Stehling on 3/27/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
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
            if let indexPath = sender as? IndexPath {
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

    fileprivate func selectRow(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Search", message: "Would you like to search for this book?", preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] (action) in
            self.editBook(at: indexPath)
        }
        let searchAction = UIAlertAction(title: "Search", style: .default) { [unowned self] (action) in
            self.searchBook(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            debugPrint("Cancel")
        }
        alertController.addAction(editAction)
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func editBook(at indexPath: IndexPath) {
        debugPrint("Edit")
        self.performSegue(withIdentifier: "editBook", sender: indexPath)
    }

    fileprivate func searchBook(at indexPath: IndexPath) {
        debugPrint("Search")
        let book = self.bookStore.fetchedResultsController.object(at: indexPath)
        let author = book.author ?? ""
        let title = book.title ?? ""
        let params = [
            "search-alias" : "stripbooks",
            "field-author" : author,
            "field-title" : title
        ]
        let baseURLString = "https://www.amazon.com/gp/search/ref=sr_adv_b/"
        if let searchURL = self.urlWithString(baseURLString, parameters: params) {
            let safariViewController = SFSafariViewController(url: searchURL)
            safariViewController.delegate = self
            self.present(safariViewController, animated: true, completion: nil)
        }
    }

    fileprivate func urlWithString(_ string: String?, parameters: [String : Any]?) -> URL? {
        guard let string = string
            else {
                return nil
        }

        let aURL = URL(string: string)
        if aURL?.scheme != "http" && aURL?.scheme != "https" {
            return nil
        }

        if let parameters = parameters {
            return appendQueryParameters(parameters, aURL: aURL)
        }

        return aURL
    }

    fileprivate func appendQueryParameters(_ parameters: [String : Any], aURL: URL?) -> URL? {
        guard let aURL = aURL else { return nil }
        var components = URLComponents(url: aURL, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.flatMap {
            return URLQueryItem(name: $0, value: "\($1)")
        }

        return components?.url
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectRow(at: indexPath)
    }

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

extension ViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        debugPrint("Did Finish")
    }

    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        debugPrint("Did Load Successfully")
    }

}
