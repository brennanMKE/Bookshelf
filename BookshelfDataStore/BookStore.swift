//
//  BookStore.swift
//  Bookshelf
//
//  Created by Brennan Stehling on 3/27/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import CoreData

/// Book Store using Core Data
open class BookStore: NSObject {

    public var fetchRequest: NSFetchRequest<Book> {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

    lazy public var fetchedResultsController: NSFetchedResultsController<Book> = {
        let context = DataStoreManager.sharedInstance.context
        return NSFetchedResultsController(fetchRequest: self.fetchRequest,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()

    open func fetchBooks() -> [Book] {
        let context = DataStoreManager.sharedInstance.context
        let results = try? context.fetch(fetchRequest)
        guard let books = results else {
            return []
        }
        return books
    }

    @discardableResult
    open func createBook(bookId: String, title: String, author: String, saveContext: Bool = true) -> Book {
        let context = DataStoreManager.sharedInstance.context
        let book = Book(context: context)
        book.bookId = bookId
        book.title = title
        book.author = author
        if saveContext {
            DataStoreManager.sharedInstance.saveContext()
        }
        return book
    }

    open func updateBook(_ book: Book, title: String, author: String, saveContext: Bool = true) {
        book.title = title
        book.author = author
        if saveContext {
            DataStoreManager.sharedInstance.saveContext()
        }
    }

    open func deleteBook(_ book: Book, saveContext: Bool = true) {
        let context = DataStoreManager.sharedInstance.context
        context.delete(book)
        if saveContext {
            DataStoreManager.sharedInstance.saveContext()
        }
    }

}
