//
//  ExtensionCharacterVC.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/30/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation
import UIKit
import SQLite


extension CharacterVC
{
    
    func getCharacterCharVC(type: String, membershipId: String, characterId: String)
    {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        //Components 201 = will grab all items in the characters inventory.
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/\(type)/Profile/\(membershipId)/Character/\(characterId)/?components=200,201")
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            request.addValue("Bearer \(currentUserCharVC!.userAccessToken)" , forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request, completionHandler: { (opt_data, opt_response, opt_error) in
                
                //Bail Out on error
                if opt_error != nil { return }
                
                //Check the response, statusCode, and data
                guard let response = opt_response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = opt_data
                    else { print("JSON object creation failed"); return }
                
                do
                {
                    //De-Serialize data object
                    //First level object is a dictionary.
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    {
                        guard let response = jsonObject["Response"] as? [String: Any]
                            else { return }
                        
                        //Add an array to hold all the items information that we get.
                        var itemArray = [ItemInfo]()
                        
                        var iHash = 0
                        var iId = ""
                        var iBucketHash = 0
                        var itemType = ""
                        
                        if let inventory = response["inventory"] as? [String: Any]
                        {
                            if let data = inventory["data"] as? [String: Any]
                            {
                                //Go through and grab all items in the inventory.
                                if let items = data["items"] as? [[String: Any]]
                                {
                                    for item in items
                                    {
                                        if let itemBucketHash = item["bucketHash"] as? Int
                                        {
                                            iBucketHash = itemBucketHash
                                            
                                            //This will grab the weapons and armor on a character.
                                            if iBucketHash == 1498876634 || iBucketHash == 2465295065 || iBucketHash == 953998645 || iBucketHash == 3448274439 || iBucketHash == 3551918588 || iBucketHash == 14239492 || iBucketHash == 20886954 || iBucketHash == 1585787867
                                            {
                                                //Add the other buckets in here when working again
                                                switch iBucketHash
                                                {
                                                case 1498876634:
                                                    itemType = "Kinetic"
                                                case 2465295065:
                                                    itemType = "Energy"
                                                case 953998645:
                                                    itemType = "Power"
                                                case 3448274439:
                                                    itemType = "Helm"
                                                case 3551918588:
                                                    itemType = "Gauntlet"
                                                case 14239492:
                                                    itemType = "Chest"
                                                case 20886954:
                                                    itemType = "Leg"
                                                case 1585787867:
                                                    itemType = "Class"
                                                default:
                                                    print("Hash undetectable.")
                                                }
                                                
                                                if let itemHash = item["itemHash"] as? Int
                                                {
                                                    iHash = itemHash
                                                }
                                                if let itemId = item["itemInstanceId"] as? String
                                                {
                                                    iId = itemId
                                                }
                                                
                                                //Create new item and append it to the itemArray.
                                                itemArray.append(ItemInfo(itemHash: iHash, itemInstance: iId, bucketHash: iBucketHash, itemType: itemType))
                                            }
                                        }
                                    }
                                    //Character gets their specific inventory refreshed
                                    self.characters[self.selection].characterItemInventory.removeAll()
                                    self.characters[self.selection].characterItemInventory.append(contentsOf: itemArray)
                                }
                            }
                        }
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async
                    {
                        self.loadItemInfo()
                }
            })
            task.resume()
        }
        //End of getCharacter
    }
    
    
    
    
    //This function will query the manifest for destiny 2 items information.
    func queryManifestForItemInfo(itemHash: Int, characterIndex: Int, itemIndex: Int)
    {
        let fileManager = FileManager.default
        
        var items = [String]()
        
        do
        {
            items = try fileManager.contentsOfDirectory(atPath: self.getDocumentDirectoryPath() + "/MyDestinyManifest")
        } catch {
            print("Error found while searching for database path, Error: " + error.localizedDescription)
        }
        
        var fileName = ""
        for item in items
        {
            fileName = item
        }
        
        //Database path
        let databasePath = self.getDocumentDirectoryPathCharVC() + "/MyDestinyManifest/" + fileName
        
        do
        {
            //Database
            let db = try Connection(databasePath)
            
            //Table to query against
            let itemTable = Table("DestinyInventoryItemDefinition")
            
            //Table columns
            let id = Expression<Int64>("id")
            let description = Expression<String>("json")
            
            //Run the query and store the item information.
            do
            {
                //Convert the hash, if it can't be converted then just use the original hash.
                let itemQueryId = convertHashCharVC(input: itemHash) ?? itemHash
                
                //Setup the query.
                let query = itemTable.select(description)
                    .filter(id == Int64(itemQueryId))
                
                //Run the query
                for item in try db.prepare(query)
                {
                    let data = Data(item[description].utf8)
                    
                    do {
                        //Database returns JSON as the item description.
                        if let json_Obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            if let displayProperties = json_Obj["displayProperties"] as? [String: Any] {
                                
                                var itemName = ""
                                var itemDescription = ""
                                var itemIconPath = ""
                                
                                if let name = displayProperties["name"] as? String
                                {
                                    itemName = name
                                }
                                if let description = displayProperties["description"] as? String
                                {
                                    itemDescription = description
                                }
                                
                                if let hasPath = displayProperties["hasIcon"] as? Bool
                                {
                                    if hasPath
                                    {
                                        if let path = displayProperties["icon"] as? String
                                        {
                                            itemIconPath = path
                                            self.itemImageTaskTotalCharVC += 1
                                        }
                                    }
                                }
                                
                                //This is where we store all of the info of an item to the character.
                                self.characters[self.selection].characterItemInventory[itemIndex].itemIconPath = itemIconPath
                                self.characters[self.selection].characterItemInventory[itemIndex].itemName = itemName
                                self.characters[self.selection].characterItemInventory[itemIndex].itemDescription = itemDescription
                            }
                            
                            
                        }
                    } catch {
                        print("Failed to create Json_Obj: \(error.localizedDescription)")
                    }
                    
                    
                }
                
                itemTaskCounterCharVC += 1
                
                if itemTaskCounterCharVC == itemTotalTaskCharVC
                {
                    DispatchQueue.main.async {
                        //Perform final load check.
                        self.loadItemImages()
                    }
                }
            } catch {
                print("Error found while running query, Error: " + error.localizedDescription)
            }
            
        } catch {
            print("Error found at connection to database, Error: " + error.localizedDescription)
        }
        //End of qeury function.
    }
    
    //This fucntion will grab all of the icons for every item associated to a character.
    func getItemIconImgCharVC(characterIndex: Int, itemIndex: Int, path: String, apiKey: String)
    {
        let rootPath = "https://www.bungie.net"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: rootPath + path)
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let dispatch = DispatchGroup()
            let task = session.dataTask(with: request, completionHandler: { (opt_data, opt_response, opt_error) in
                
                dispatch.enter()
                //Bail Out on error
                if opt_error != nil { return }
                
                //Check the response, statusCode, and data
                guard let response = opt_response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = opt_data
                    else { print("JSON object creation failed"); return }
                
                //Grab the image and store it to the correct item.
                if let itemIcon = UIImage(data: data)
                {
                    self.characters[self.selection].characterItemInventory[itemIndex].itemIcon = itemIcon
                }
                
                dispatch.leave()
                
                dispatch.notify(queue: DispatchQueue.main, execute: {
                    self.itemImageTaskCounterCharVC += 1
                    
                    if self.itemImageTaskTotalCharVC == self.itemImageTaskCounterCharVC
                    {
                        DispatchQueue.main.async {
                            
                            //All items have their information and icons, so now we can segue to display them.
                            self.performSegue(withIdentifier: "segueToInventoryScreen", sender: self)
            
                        }
                    }
                })
            })
            task.resume()
        }
        //End of getEmblemBackImg
    }
    
    
    //MARK: Misc. functions
    
    //This function will run to get all the items info from the manifest.
    func loadItemInfo() {
        getItemTotalTaskCharVC()
        
        for (i, item) in characters[selection].characterItemInventory.enumerated()
        {
            self.queryManifestForItemInfo(itemHash: item.itemHash, characterIndex: selection, itemIndex: i)
        }
    }
    
    //This function will run to get all the items on the character their icon.
    func loadItemImages()
    {
        for (i, item) in characters[selection].characterItemInventory.enumerated()
        {
            getItemIconImgCharVC(characterIndex: self.selection, itemIndex: i, path: item.itemIconPath, apiKey: apiKey)
        }
    }
    
    
    //This function will get the total number of tasks that need to be completed before program can segue to the next screen.
    func getItemTotalTaskCharVC()
    {
        for _ in characters[selection].characterItemInventory
        {
            self.itemTotalTaskCharVC += 1
        }
    }
    
    //This function will return a converted hash number for querying in the manifest.
    func convertHashCharVC(input: Int) -> Int?
    {
        var returnInt:Int? = nil
        
        if (input & (1 << (32 - 1))) != 0
        {
            returnInt = input - (1 << 32)
        }
        
        return returnInt
    }
    
    //This function will return the directory path of the device, used for finding the manifest.
    func getDocumentDirectoryPathCharVC() -> String
    {
        var returnString = ""
        
        //This is how to get the document path for a device.
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path
        {
            returnString = documentsPath
        }
        
        return returnString
    }
    
    
    
}
