//
//  DetailViewController.swift
//  Bookshelf
//
//  Created by Brennan Stehling on 3/27/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var authorTextField: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }

    fileprivate func saveBook() {
        guard let title = titleTextField.text,
            let author = authorTextField.text else {
                return
        }

        // dismiss keyboard
        setEditing(false, animated: true)

        let bookId = UUID().uuidString
        let bookStore = BookStore()
        bookStore.createBook(bookId: bookId, title: title, author: author)
        performSegue(withIdentifier: "returnHome", sender: self)
    }

}

extension DetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
