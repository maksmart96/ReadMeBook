//
//  ViewController.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 19.03.2022.

import UIKit
import CoreData

class LibraryHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "\(LibraryHeaderView.self)"
}

enum SortStyle {
    case title
    case author
    case readMe
}

enum Section: String, CaseIterable {
    case addNew
    case readMe = "Read Me!"
    case finished = "Finished"
}


class LibraryViewController: UITableViewController {
    
//    var context: NSManagedObjectContext?
    
    var dataSource: diffableDS!
    
    @IBOutlet var sortButtons: [UIBarButtonItem]!
    
    @IBAction func sortByTitle(_ sender: UIBarButtonItem) {
        dataSource.update(sortStyle: .title)
        updateTintColor(tappedButton: sender)
    }
    
    @IBAction func sortByAuthor(_ sender: UIBarButtonItem) {
        dataSource.update(sortStyle: .author)
        updateTintColor(tappedButton: sender)
    }
    
    @IBAction func sortByReadMe(_ sender: UIBarButtonItem) {
        dataSource.update(sortStyle: .readMe)
        updateTintColor(tappedButton: sender)
    }
    
    func updateTintColor(tappedButton: UIBarButtonItem) {
        sortButtons.forEach { button in
//            if button == tappedButton {
//                button.tintColor = .systemBlue
//            } else {
//                button.tintColor = .secondaryLabel
//            }
            button.tintColor = button == tappedButton
            ? .systemBlue
            : .secondaryLabel
        }
    }
    
    @IBSegueAction func showDetailView(_ coder: NSCoder) -> DetailViewController? {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let book = dataSource.itemIdentifier(for: indexPath)
        else {
            fatalError("nothing is selected!!")
            }
       
        
        return DetailViewController(book: book, coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        
        
        tableView.register(UINib(nibName: "\(LibraryHeaderView.self)", bundle: nil), forHeaderFooterViewReuseIdentifier: LibraryHeaderView.reuseIdentifier)
        configureDataSource()
        dataSource.update(sortStyle: .readMe, animatingDifferences: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.update(sortStyle: dataSource.currentSortStyle, animatingDifferences: false)
    }
    
    
    
    //MARK: - Delegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LibraryHeaderView.reuseIdentifier) as? LibraryHeaderView
            else { return nil }
            
            return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 60 : 0
    }
    
    //MARK: - DataSource
func configureDataSource() {
    dataSource = diffableDS(tableView: tableView) { tableView, indexPath, book -> UITableViewCell? in
        if indexPath == IndexPath(row: 0, section: 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewBookCell", for: indexPath)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(BookCell.self)", for: indexPath) as? BookCell else { fatalError("cannot deque cell") }
                
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        cell.thumbnail.image = book.image ?? LibrarySymbol.letterSquare(letter: book.title.first).image
        cell.thumbnail.layer.cornerRadius = 12
        if let review = book.review {
          cell.reviewLabel.text = review
          cell.reviewLabel.isHidden = false
        }
        cell.bookMark.isHidden = !book.readMe
        return cell
    }
}
}
    
    

class diffableDS: UITableViewDiffableDataSource<Section, Book> {
    var currentSortStyle: SortStyle = .title
    
    
    func update(sortStyle: SortStyle, animatingDifferences: Bool = true) {
        currentSortStyle = sortStyle
        
      var newSnapshot = NSDiffableDataSourceSnapshot<Section, Book>()
      newSnapshot.appendSections(Section.allCases)
      let booksByReadMe: [Bool: [Book]] = Dictionary(grouping: Library.books, by: \.readMe)
      for (readMe, books) in booksByReadMe {
          var sortedBooks: [Book]
          switch sortStyle {
          case .title:
              sortedBooks = books.sorted { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending
              }
          case .author:
              sortedBooks = books.sorted(by: { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending })
          case .readMe:
              sortedBooks = books
          }
          
        newSnapshot.appendItems(sortedBooks, toSection: readMe ? .readMe : .finished)
      }
      newSnapshot.appendItems([Book.mockBook], toSection: .addNew)
      apply(newSnapshot, animatingDifferences: animatingDifferences)
    }
        
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == snapshot().indexOfSection(.addNew) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let book = self.itemIdentifier(for: indexPath) else { return }
            Library.delete(book: book)
            update(sortStyle: currentSortStyle,animatingDifferences: false)
    }
}

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != snapshot().indexOfSection(.readMe) &&
           currentSortStyle == .readMe {
            return false
        } else {
            return true
        }
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard
        sourceIndexPath != destinationIndexPath,
        sourceIndexPath.section == destinationIndexPath.section,
        let bookToMove = itemIdentifier(for: sourceIndexPath),
        let bookAtDestination = itemIdentifier(for: destinationIndexPath)
        else {
            apply(snapshot(), animatingDifferences: false)
            return
        }
        Library.reorderBooks(bookToMove: bookToMove, bookAtDestination: bookAtDestination)
        update(sortStyle: currentSortStyle, animatingDifferences: false)
    }
}

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return section == 0 ? 1 : Library.books.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath == IndexPath(row: 0, section: 0) {
//             let cell = tableView.dequeueReusableCell(withIdentifier: "NewBookCell", for: indexPath)
//            return cell
//        }
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(BookCell.self)", for: indexPath) as? BookCell else { fatalError("cannot find cell!!") }
//
//        let book = Library.books[indexPath.row]
//
//        cell.titleLabel.text = book.title
//        cell.authorLabel.text = book.author
//        cell.thumbnail.image = book.image
//        cell.thumbnail.layer.cornerRadius = 12
//
//        return cell
//        }

