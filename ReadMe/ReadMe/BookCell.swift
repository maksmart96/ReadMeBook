//
//  BookCell.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 11.04.2022.
//

import UIKit

class BookCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var reviewLabel: UILabel!
    
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var bookMark: UIImageView!
    
    override func prepareForReuse() {
      reviewLabel.text = nil
      reviewLabel.isHidden = true
    }
}
