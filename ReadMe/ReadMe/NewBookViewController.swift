//
//  NewBookViewController.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 13.04.2022.
//

import UIKit

class NewBookViewController: UITableViewController {
   // var book: Book
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var addImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    var newBookImage: UIImage?


    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBook() {
        guard let title = titleTextField.text,
              let author = authorTextField.text,
              !title.isEmpty,
              !author.isEmpty else { return }
        
        Library.addNew(book: Book(title: title, author: author, readMe: true, image: newBookImage))
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera)
            ? .camera
            : .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    override func viewDidLoad() {
        imageView.layer.cornerRadius = 16
    }
   
}

extension NewBookViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        imageView.image = selectedImage
        newBookImage = selectedImage
        dismiss(animated: true)
    }
}

extension NewBookViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            return authorTextField.becomeFirstResponder()
        } else {
            return textField.resignFirstResponder()
        }
    }
}


