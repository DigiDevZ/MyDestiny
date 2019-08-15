//
//  ItemInfo.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/26/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation
import UIKit

class ItemInfo {
    
    //Stored
    var itemHash = 0
    var itemInstance = ""
    var bucketHash = 0
    
    //ItemType is based on the bucket of the item.
    var itemType = ""
    
    //These variables are retrieved later on in the program.s
    var itemIcon = UIImage()
    var itemIconPath = ""
    var itemName = ""
    var itemDescription = ""
    
    //Inits
    init(itemHash: Int, itemInstance: String, bucketHash: Int, itemType: String)
    {
        self.itemHash = itemHash
        self.itemInstance = itemInstance
        self.bucketHash = bucketHash
        self.itemType = itemType
    }

}
