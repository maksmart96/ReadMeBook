//
//  Library.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 10.04.2022.
//

import UIKit

enum LibrarySymbol {
    case bookmark
    case bookmarkFill
    case book
    case letterSquare(letter: Character?)
    
    var image: UIImage {
        let imageName: String
        switch self {
        case .bookmark, .book:
            imageName = "\(self)"
        case .bookmarkFill:
            imageName = "bookmark.fill"
        case .letterSquare(letter: let letter):
            guard let letter = letter?.lowercased(),
            let image = UIImage(systemName: "\(letter).square") else {
                imageName = "square"
                break
            }
           return image
        }
        return UIImage(systemName: imageName)!
    }
}

enum Library {
    
    static let starterData: [Book] = [
        Book(title: "Последнее Желание", author: "Анжей Сапковский", readMe: true),
        Book(title: "Меч Предназначения", author: "Анжей Сапковский", readMe: true),
        Book(title: "Кровь Эльфов", author: "Анжей Сапковский", readMe: true),
        Book(title: "Час Презрения", author: "Анжей Сапковский", readMe: false),
        Book(title: "Крещение Огнем", author: "Анжей Сапковский", readMe: true),
        Book(title: "Башня Ласточки ", author: "Анжей Сапковский", readMe: false),
        Book(title: "Владычица Озера", author: "Анжей Сапковский", readMe: true)
    ]
    
    static var books: [Book] = loadBooks()
    
    static let booksJSONURL = URL(fileURLWithPath: "Books", relativeTo: FileManager.documentDirectoryURL).appendingPathExtension("json")
    
    //MARK: - Методы с книгами
    private static func loadBooks() -> [Book] {
        let decoder = JSONDecoder()
        
        guard let booksData = try? Data(contentsOf: booksJSONURL)
        else {
            return starterData
        }
        do {
            let books = try decoder.decode([Book].self, from: booksData)
             
            return books.map { libraryBook in
                Book(title: libraryBook.title,
                     author: libraryBook.author,
                     review: libraryBook.review,
                     readMe: libraryBook.readMe,
                     image: loadImage(forBook: libraryBook))
            }
        } catch {
            print(error)
            return starterData
        }
    }
    
    private static func saveAllBooks() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let booksData = try encoder.encode(books)
            try booksData.write(to: booksJSONURL, options: .atomicWrite)
        } catch let error {
            print(error)
        }
    }
    
    static func addNew(book: Book) {
        if let image = book.image { saveImage(image, forBook: book) }
        books.insert(book, at: 0)
        saveAllBooks()
    }
    
    static func update(book: Book) {
        if let image = book.image { saveImage(image, forBook: book) }
        
        guard let bookIndex = books.firstIndex(where: { storedBook in
            book.title == storedBook.title
        }) else {
            print("No book to update")
            return
        }
                
        books[bookIndex] = book
        saveAllBooks()
    }
    
    static func delete(book: Book) {
       guard let bookIndex = books.firstIndex(where: { storedBook in
            book.title == storedBook.title
       }) else {
           print("No book to delete")
           return
       }
        books.remove(at: bookIndex)
        
        let imageURL = FileManager.documentDirectoryURL.appendingPathComponent(book.title)
       
        do {
            try FileManager().removeItem(at: imageURL)
        } catch let error {
            print(error)
        }
        saveAllBooks()
    }
    
    static func reorderBooks(bookToMove: Book, bookAtDestination: Book) {
        let destinationIndex = books.firstIndex(of: bookAtDestination) ?? 0
        
        books.removeAll(where: { $0.title == bookAtDestination.title })
        
        books.insert(bookToMove, at: destinationIndex)
        saveAllBooks()
    }
    
    //MARK: - Images - Изображения
    static func saveImage(_ image: UIImage, forBook book: Book) {
        let imageURL = FileManager.documentDirectoryURL.appendingPathComponent(book.title)
        if let jpegData = image.jpegData(compressionQuality: 0.7) {
            try? jpegData.write(to: imageURL, options: .atomic)
        }
    }
    
    static func loadImage(forBook book: Book) -> UIImage? {
        let imageURL = FileManager.documentDirectoryURL.appendingPathComponent(book.title)
        
        return UIImage(contentsOfFile: imageURL.path)
    }
}


extension FileManager {
    static var documentDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
