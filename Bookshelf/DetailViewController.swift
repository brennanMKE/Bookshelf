//
//  DetailViewController.swift
//  Bookshelf
//
//  Created by Brennan Stehling on 3/27/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import UIKit
import BookshelfDataStore

class DetailViewController: UIViewController {

    // MARK: - Properties -

    @IBOutlet var bookStore: BookStore!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    var book: Book?

    // MARK: - View Lifecycle -

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isEditing = book != nil
        titleLabel.text = isEditing ? "Edit a Book" : "Add a Book"
        titleTextField.text = book?.title
        authorTextField.text = book?.author
        updateSaveButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }

    // MARK: - User Actions -

    @IBAction func cancelButtonTapped(_ sender: Any) {
        returnHome()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        saveBook()
    }

    // MARK: - Private -

    fileprivate var canSave: Bool {
        return titleTextField.text?.characters.count ?? 0 > 0 &&
            authorTextField.text?.characters.count ?? 0 > 0
    }

    fileprivate func saveBook() {
        if !canSave {
            return
        }

        guard let title = titleTextField.text,
            let author = authorTextField.text else {
                return
        }

        if let book = book {
            bookStore.updateBook(book, title: title, author: author)
        }
        else {
            let bookId = UUID().uuidString
            bookStore.createBook(bookId: bookId, title: title, author: author)
        }

        returnHome()
    }

    fileprivate func updateSaveButton() {
        saveButton.isHidden = !canSave
    }

    fileprivate func returnHome() {
        // dismiss keyboard
        setEditing(false, animated: true)
        performSegue(withIdentifier: "returnHome", sender: self)
    }

}

extension DetailViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            [weak self] in
            self?.updateSaveButton()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateSaveButton()
        defer {
            if textField == titleTextField {
                authorTextField.becomeFirstResponder()
            }
            else {
                saveBook()
            }
        }
        return false
    }

}
