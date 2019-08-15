//
//  ItemCollectionViewCell.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/27/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool
        {
        didSet {
            if self.isSelected
            {
            
            }
            else
            {
                //Do nothing.
            }
        }
    }
    
}
