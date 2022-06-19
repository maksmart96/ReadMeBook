//
//  DetailViewController.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 10.04.2022.
//

import UIKit

class DetailViewController: UITableViewController {
    var book: Book
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var readMeButton: UIButton!
    
    
    @IBAction func toggleReadMe() {
        book.readMe.toggle()
        let image = book.readMe ? LibrarySymbol.bookmarkFill.image : LibrarySymbol.bookmark.image
        readMeButton.setImage(image, for: .normal)
    }
    
    @IBAction func saveChanges() {
        Library.update(book: book)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType =
        UIImagePickerController.isSourceTypeAvailable(.camera)
                ? .camera
                : .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let review = book.review {
            reviewTextView.text = review
        }
        let image = book.readMe
            ? LibrarySymbol.bookmarkFill.image
            : LibrarySymbol.bookmark.image
        readMeButton.setImage(image, for: .normal)
        
        titleLabel.text = book.title
        authorLabel.text = book.author
        detailImage.image = book.image ?? LibrarySymbol.letterSquare(letter: book.title.first).image
        detailImage.layer.cornerRadius = 16
        reviewTextView.addDoneButton()
    }
    
    init?(book: Book, coder: NSCoder) {
        self.book = book
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       guard let selectedImage = info[.editedImage] as? UIImage
        else { return }
        
        detailImage.image = selectedImage
        book.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        book.review = textView.text
        textView.resignFirstResponder()
    }
}

extension UITextView {
    func addDoneButton() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.resignFirstResponder))
       
        toolbar.items = [flexibleSpace, doneButton]
        self.inputAccessoryView = toolbar
    }
}
