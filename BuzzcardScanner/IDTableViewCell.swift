//
//  IDTableViewCell.swift
//  BuzzScan
//
//  Created by Bao Vu on 1/26/16.
//
//

import UIKit

class IDTableViewCell: UITableViewCell {
    
    @IBOutlet weak var id: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
