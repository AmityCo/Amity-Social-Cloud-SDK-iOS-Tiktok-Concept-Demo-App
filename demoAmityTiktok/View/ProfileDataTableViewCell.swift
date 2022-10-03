//
//  ProfileDataTableViewCell.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 22/9/2565 BE.
//

import UIKit

class ProfileDataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var arrowSymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
