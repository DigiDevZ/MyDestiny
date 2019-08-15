//
//  ItemVC.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/27/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ItemVC: UIViewController {
    
    var apiKey = ""
    
    var characters = [CharacterInfo]()
    var senderCharacterId = ""
    var receiverCharacter = ""
    
    var itemName = ""
    var itemImage = UIImage()
    var itemId = ""
    var itemHash = 0
    var itemDescription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemNameLabel.text = itemName
        itemImageView.image = itemImage
        itemDescriptionText.text = itemDescription
     
    }
    
    //MARK: Outlets
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemDescriptionText: UITextView!
    
    
    @IBAction func transferTapped(_ sender: Any) {
        
        //Create alert for where to send item.
        transferAlert()
        
    }
    
    
    func transferItemToVault(itemHash: Int, itemId: String, characterId: String, receiverCharacter: String)
    {
        self.receiverCharacter = receiverCharacter
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/Actions/Items/TransferItem/")
        {
            var accessToken = ""
            
            if let retrievedString: String = KeychainWrapper.standard.string(forKey: "d2MyDestinyAccessToken")
            {
                accessToken = retrievedString
            }
            
            var request = URLRequest(url: validURL)
            request.httpMethod = "POST"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            request.addValue("Bearer \(accessToken)" , forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
            
            let parameters: [String: Any] = [
                "itemReferenceHash": itemHash,
                "stackSize": 1,
                "transferToVault": true,
                "itemId": itemId,
                "characterId": senderCharacterId,
                "membershipType": 1
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                
                request.httpBody = jsonData
            } catch {
                print(error.localizedDescription)
            }
            
            
            //request.httpBody = parameters.percentEscaped().data(using: .utf8)
            
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
                
                do
                {
                    //De-Serialize data object
                    //MARK: First level object is a dictionary.
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    {
                        if let response = jsonObject["ErrorStatus"] as? String
                        {
                            print("Response: " + response)
                            if response == "Success"
                            {
                                print("SENT TO VAULT.")
                            }
                        }
                        if let message = jsonObject["Message"] as? String
                        {
                            print("Message: " + message)
                        }
                        if let errorCode = jsonObject["ErrorStatus"] as? String
                        {
                            print("Error code: " + errorCode)
                        }
                    }
                    
                    dispatch.leave()
                    
                    dispatch.notify(queue: DispatchQueue.main, execute: {
                        self.transferItemToSelectedCharacter(itemHash: itemHash, itemId: itemId, characterId: characterId)
                        
                    })
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
        }
        //End of transferItemToVault
    }
    
    //This function will create an alert for saving the players game info.
    func transferAlert()
    {
        //Step 1
        let alert = UIAlertController.init(title: "Choose a destination for this item.", message: "Select from any of the options.", preferredStyle: .alert)
        
        //Step 2
        
        for character in characters
        {
            if character.characterId != senderCharacterId
            {
                let action = UIAlertAction.init(title: character.characterClass, style: .default, handler:
                {_ in
                    self.transferItemToVault(itemHash: self.itemHash, itemId: self.itemId, characterId: character.characterId, receiverCharacter: character.characterClass)
                    
                })
                alert.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        
        //Step 3
        alert.addAction(cancelAction)
        
        //Step 4
        present(alert, animated: true, completion: nil)
        
    }
    
    //Now transfer the item to the selected character.
    func transferItemToSelectedCharacter(itemHash: Int, itemId: String, characterId: String)
    {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        //Add component for items later.
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/Actions/Items/TransferItem/")
        {
            var accessToken = ""
            
            if let retrievedString: String = KeychainWrapper.standard.string(forKey: "d2MyDestinyAccessToken")
            {
                accessToken = retrievedString
            }
            
            var request = URLRequest(url: validURL)
            request.httpMethod = "POST"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            request.addValue("Bearer \(accessToken)" , forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
            
            let parameters: [String: Any] = [
                "itemReferenceHash": itemHash,
                "stackSize": 1,
                "transferToVault": false,
                "itemId": itemId,
                "characterId": characterId,
                "membershipType": 1
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                
                request.httpBody = jsonData
            } catch {
                print(error.localizedDescription)
            }
            
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
                    //MARK: First level object is a dictionary.
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    {
                        if let response = jsonObject["ErrorStatus"] as? String
                        {
                            print("Response: " + response)
                            if response == "Success"
                            {
                                print("WE DID IT BOIS")
                                
                                DispatchQueue.main.async {
                                    self.successAlert()
                                }
                                
                            }
                        }
                        if let message = jsonObject["Message"] as? String
                        {
                            print("Message: " + message)
                        }
                        if let errorCode = jsonObject["ErrorStatus"] as? String
                        {
                            print("Error code: " + errorCode)
                        }
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
        }
        //End of transferItemToVault
    }
    
    
    //This function will create an alert for saving the players game info.
    func successAlert()
    {
        //Step 1
        let alert = UIAlertController.init(title: "Item successfully transferred to: ", message: "\(receiverCharacter)", preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: {_ in
            
            self.performSegue(withIdentifier: "unwindSegueToInventory", sender: self)
        })
        
        alert.addAction(okAction)
        
        //Step 4
        present(alert, animated: true, completion: nil)
        
    }
    
    //After ok action in success alert, segue the user back to the inventory.
    
    
    
}


