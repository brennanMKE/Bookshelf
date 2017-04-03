//
//  BookshelfDataStoreTests.swift
//  BookshelfDataStoreTests
//
//  Created by Brennan Stehling on 3/28/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import XCTest
@testable import BookshelfDataStore

class BookshelfDataStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        purgeAllBooks()
    }

    func testCreatingASingleBook() {
        let bookStore = BookStore()
        let book = bookStore.createBook(bookId: UUID().uuidString, title: "My Life", author: "Jerry Seinfeld")
        XCTAssertNotNil(book)
    }

    func testCreatingMultipleBooks() {
        let bookStore = BookStore()
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
            let book = bookStore.createBook(bookId: bookId, title: title, author: author, saveContext: false)
            XCTAssertNotNil(book)
        })
        DataStoreManager.sharedInstance.saveContext()
    }

    // MARK: - Private -

    private func purgeAllBooks() {
        let bookStore = BookStore()
        let books = bookStore.fetchBooks()
        books.forEach {
            bookStore.deleteBook($0, saveContext: false)
        }
        DataStoreManager.sharedInstance.saveContext()
    }
    
}
