//
//  CharacterInfo.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation
import UIKit

class CharacterInfo : NSObject, NSCoding{
    
    //Stored
    var characterId = ""
    var characterLight = 0
    
    //This var will help with the computed function.
    var characterClassType = -1
    
    var characterEmblemPath = ""
    var characterEmblemBackPath = ""
    var characterLevel = 0
    
    //Stored variable of array of items
    var characterItemInventory = [ItemInfo]()
    
    //Stored variables for the images, only after we call them.
    var characterEmblemBack = UIImage()
    
    //Computed
    //Computed function for the class type of the character
    var characterClass: String
    {
        var characterClassName = ""
        
        switch characterClassType
        {
        case 0:
            characterClassName =  "Titan"
        case 1:
            characterClassName = "Hunter"
        case 2:
            characterClassName = "Warlock"
        default:
            print("No class associated with character.")
        }
        
        return characterClassName
    }
    
    //Inits
    init(characterId: String, characterLight: Int, characterClassType: Int, characterEmblemPath: String, characterEmblemBackPath: String, characterLevel: Int)
    {
        self.characterId = characterId
        self.characterLight = characterLight
        self.characterClassType = characterClassType
        self.characterEmblemPath = characterEmblemPath
        self.characterEmblemBackPath = characterEmblemBackPath
        self.characterLevel = characterLevel
    }
    
    //Functions to conform to NSCoding.
    
    //To decode the object
    required convenience init?(coder aDecoder : NSCoder) {
        self.init(characterId: "0", characterLight: 0, characterClassType: 0, characterEmblemPath: "0", characterEmblemBackPath: "0", characterLevel: 0)
        
        characterId = aDecoder.decodeObject(forKey: "characterId") as! String
        characterLight = aDecoder.decodeObject(forKey: "characterLight") as! Int
        characterClassType = aDecoder.decodeObject(forKey: "characterClassType") as! Int
        characterEmblemPath = aDecoder.decodeObject(forKey: "characterEmblemPath") as! String
        characterEmblemBackPath = aDecoder.decodeObject(forKey: "characterEmblemBackPath") as! String
        characterLevel = aDecoder.decodeObject(forKey: "characterLevel") as! Int
        
        characterItemInventory = aDecoder.decodeObject(forKey: "characterItemInventory") as! [ItemInfo]
        characterEmblemBack = aDecoder.decodeObject(forKey: "characterEmblemBack") as! UIImage
    }
    
    //To encode the object
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(characterId, forKey: "characterId")
        aCoder.encode(characterLight, forKey: "characterLight")
        aCoder.encode(characterClassType, forKey: "characterClassType")
        aCoder.encode(characterEmblemPath, forKey: "characterEmblemPath")
        aCoder.encode(characterEmblemBackPath, forKey: "characterEmblemBackPath")
        aCoder.encode(characterLevel, forKey: "characterLevel")
        aCoder.encode(characterEmblemBack, forKey: "characterEmblemBack")
    }
    
    
}
