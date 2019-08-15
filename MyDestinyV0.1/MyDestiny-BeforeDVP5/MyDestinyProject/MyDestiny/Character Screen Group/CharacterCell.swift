//
//  CharacterCell.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit

class CharacterCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var emblemBackgroundImg: UIImageView!
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var lightLevelLabel: UILabel!
    
    

}
