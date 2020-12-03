//
//  RouteCell.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 18.11.2020.
//  Quality Assurance by Kateryna Galushka
//

import UIKit

final class RouteCell:UITableViewCell {
    
    @IBOutlet weak var iconImageView:UIImageView!
    @IBOutlet weak var timerTitle:UILabel!
    @IBOutlet weak var dateTitle:UILabel!
    
    public static let reuseIdentifier:String = "routeCellReuseIdentifier"
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
}
