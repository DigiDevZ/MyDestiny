//
//  ItemInfo.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/26/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation
import UIKit

class ItemInfo : NSObject, NSCoding {
    
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
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(itemHash: 0, itemInstance: "", bucketHash: 0, itemType: "")
        
        itemHash = aDecoder.decodeObject(forKey: "itemHash") as! Int
        itemInstance = aDecoder.decodeObject(forKey: "itemInstance") as! String
        bucketHash = aDecoder.decodeObject(forKey: "bucketHash") as! Int
        
        itemType = aDecoder.decodeObject(forKey: "itemType") as! String
        
        itemIcon = aDecoder.decodeObject(forKey: "itemIcon") as! UIImage
        itemIconPath = aDecoder.decodeObject(forKey: "itemIconPath") as! String
        itemName = aDecoder.decodeObject(forKey: "itemName") as! String
        itemDescription = aDecoder.decodeObject(forKey: "itemDescription") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(itemHash, forKey: "itemHash")
        aCoder.encode(itemInstance, forKey: "itemInstance")
        aCoder.encode(bucketHash, forKey: "bucketHash")
        
        aCoder.encode(itemType, forKey: "itemType")
        
        aCoder.encode(itemIcon, forKey: "itemIcon")
        aCoder.encode(itemIconPath, forKey: "itemIconPath")
        aCoder.encode(itemName, forKey: "itemName")
        aCoder.encode(itemDescription, forKey: "itemDescription")
    }

}
