//
//  NewsTableViewCell.swift
//  News
//
//  Created by Павло Тимощук on 31.10.2020.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsSourceLabel: UILabel!
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var newsTimeLabel: UILabel!
    @IBOutlet weak var showNewsDetailView: UIImageView!
    
    var newsImage = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
