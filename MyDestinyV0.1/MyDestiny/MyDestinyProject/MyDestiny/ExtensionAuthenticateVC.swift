//
//  ExtensionAuthenticateVC.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation
import UIKit


//This extension will house the majority of the API Endpoints and gather all of the information for the user. 

extension AuthenticateVC
{
    //MARK: Endpoint functions
    func getCurrentBungieUser(accessToken: String)
    {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/Platform/User/GetCurrentBungieNetUser/")
        {
            
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            request.addValue("Bearer \(accessToken)" , forHTTPHeaderField: "Authorization")
            
            
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
                        //Parse Data
                        //Sources is a dictionary.
                        guard let response = jsonObject["Response"] as? [String: Any]
                            else { return }
                        
                        if let xboxGamertag = response["xboxDisplayName"] as? String
                        {
                            self.currentUser!.xboxDisplayName = xboxGamertag
                        }
                        if let psnGamertag = response["psnDisplayName"] as? String
                        {
                            self.currentUser!.psnDisplayName = psnGamertag
                        }
                        if let blizzGamertag = response["blizzardDisplayName"] as? String
                        {
                            self.currentUser!.blizzDisplayName = blizzGamertag
                        }
                        
                        //Load variable is good to go.
                        self.loadGetCurrentUser = true
                        self.taskCounter += 1
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
            
                DispatchQueue.main.async
                    {
                        
                        //If a user has no profiles.
                        if self.currentUser!.playerGamertags.count == 0
                        {
                            let alert = UIAlertController.init(title: "It seems you don't have any linked accounts, are you sure you play Destiny 2?", message: "I highly recommend you play the game and create an account then come back.", preferredStyle: .alert)
                            
                            let warning = UIAlertAction.init(title: "Ok.", style: .default, handler: nil)
                            
                            alert.addAction(warning)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            //If the user has profiles.
                            let alert = UIAlertController.init(title: "Please choose the account you want to access.", message: "Select from any of your accounts below.", preferredStyle: .alert)
                            
                            for tag in self.currentUser!.playerGamertags
                            {
                                let selection = UIAlertAction.init(title: tag, style: .default, handler: {_ in
                                    self.searchDestinyPlayer(gamerTag: self.encodeGamerTagForQuery(gamerTag: tag)!)
                                })
                                alert.addAction(selection)
                            }
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                }
            })
            task.resume()
        }
        //End of getCurrentBungieUser
    }
    
    func searchDestinyPlayer(gamerTag: String)
    {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/SearchDestinyPlayer/-1/\(gamerTag)/")
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey , forHTTPHeaderField: "X-API-KEY")
            
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
                        //Parse Data
                        //Sources is a dictionary.
                        guard let response = jsonObject["Response"] as? [[String: Any]]
                            else { return }
                        
                        print("DEBUG: Accessing Type and Id.")
                        for item in response
                        {
                            if let membershipId = item["membershipId"] as? String
                            {
                                print(membershipId)
                                self.currentUser!.d2membershipId = membershipId
                            }
                            if let membershipType = item["membershipType"] as? Int
                            {
                                print(membershipType)
                                self.currentUser!.d2membershipType = String(membershipType)
                            }
                        }
                        
                        //                        //Run next function searchProfile
                        //                        self.searchProfile(membershipType: self.currentUser!.d2membershipType, gameId: self.currentUser!.d2membershipId)
                        self.taskCounter += 1
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
                //If I need to update the UI do it here.
                DispatchQueue.main.async
                    {
                        print("DEBUG: end of Search destiny player method")
                        //Run next function searchProfile
                        self.searchProfile(membershipType: self.currentUser!.d2membershipType, gameId: self.currentUser!.d2membershipId)
                }
                
            })
            task.resume()
        }
        //End of searchDestinyPlayer
    }
    
    func searchProfile(membershipType: String, gameId: String)
    {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/\(membershipType)/Profile/\(gameId)/?components=100")
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            
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
                        //Parse Data
                        //Sources is a dictionary.
                        guard let response = jsonObject["Response"] as? [String: Any],
                            let profile = response["profile"] as? [String: Any],
                            let data = profile["data"] as? [String: Any]
                            else { return }
                        
                        if let characterIds = data["characterIds"] as? [String]
                        {
                            self.currentUser!.characterIds.append(contentsOf: characterIds)
                        }
                        
                        
                        
                        self.playerCharacters = self.currentUser!.characterIds.count
                        
                        self.loadSearchProfile = true
                        
                        //                        //Run next function getCharacter for the amount of characters.
                        //                        for i in 0...self.currentUser!.characterIds.count - 1
                        //                        {
                        //                            self.getCharacter(type: String(self.currentUser!.d2membershipType), membershipId: self.currentUser!.d2membershipId, characterId: self.currentUser!.characterIds[i], userCharacterIndex: i, userCharacterId: self.currentUser!.characterIds[i])
                        //                        }
                        //
                        //                        self.performSegue(withIdentifier: "segueToCharacterScreen", sender: self)
                        self.taskCounter += 1
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
                //If I need to update the UI do it here.
                DispatchQueue.main.async
                    {
                        
                        
                        print("DEBUG: end of search profile method")
                        //Run next function getCharacter for the amount of characters.
                        for i in 0...self.currentUser!.characterIds.count - 1
                        {
                            self.getCharacter(type: String(self.currentUser!.d2membershipType), membershipId: self.currentUser!.d2membershipId, characterId: self.currentUser!.characterIds[i], userCharacterIndex: i, userCharacterId: self.currentUser!.characterIds[i])
                        }
                        
                        
                }
            })
            task.resume()
        }
        //End of searchProfile
    }
    
    
    func getCharacter(type: String, membershipId: String, characterId: String, userCharacterIndex: Int, userCharacterId: String)
    {
        
        // Replace the endpoint with https://www.bungie.net/Platform/Destiny2/1/Profile/4611686018430922255/Character/2305843009261719304/?components=200,201
        //And add in the authorization with access token bearer. in a headerfield.
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        //Add component for items later.
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/\(type)/Profile/\(membershipId)/Character/\(characterId)/?components=200,201")
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            request.addValue("Bearer \(currentUser!.userAccessToken)" , forHTTPHeaderField: "Authorization")
            
            
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
                        guard let response = jsonObject["Response"] as? [String: Any],
                            let character = response["character"] as? [String: Any],
                            let data = character["data"] as? [String: Any]
                            else { return }
                        
                        //MARK: Need to implement class for character info, use it as an array for the user info.
                        
                        var cLight = 0
                        var cLevel = 0
                        var cClassType = 0
                        var cEmblem = ""
                        var cEmblemBack = ""
                        
                        
                        //Capture light, emblemBackgroundPath, baseCharacterLevel, classType, emblemPath
                        if let light = data["light"] as? Int
                        {
                            cLight = light
                        }
                        if let level = data["baseCharacterLevel"] as? Int
                        {
                            cLevel = level
                        }
                        if let classType = data["classType"] as? Int
                        {
                            cClassType = classType
                        }
                        if let emblem = data["emblemPath"] as? String
                        {
                            cEmblem = emblem
                        }
                        if let emblemBack = data["emblemBackgroundPath"] as? String
                        {
                            cEmblemBack = emblemBack
                        }
                        
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
                                            
                                            //This only grabs weapons for now
                                            if iBucketHash == 1498876634 || iBucketHash == 2465295065 || iBucketHash == 953998645 
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
                                                default:
                                                    print("Bad error finding the bucket hash, it messed up real bad.")
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
                                    
                                    //Characters now have their inventory.
                                    self.currentUser!.userCharacters.append(CharacterInfo(characterId: userCharacterId, characterLight: cLight, characterClassType: cClassType, characterEmblemPath: cEmblem, characterEmblemBackPath: cEmblemBack, characterLevel: cLevel))
                                    
                                    //This is bugging out every other time, not sure why. 
                                    //self.currentUser!.userCharacters[userCharacterIndex - 1].getEmblemBackImg(path: self.currentUser!.userCharacters[userCharacterIndex - 1].characterEmblemBackPath, apiKey: self.apiKey)
                                    
                                    
                                    
                                    print("DEBUG: End of character load \(userCharacterIndex)")
                                    
                                    self.characterTaskCounter += 1
                                    
                                }
                            }
                        }
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
                //If I need to update the UI do it here.
                DispatchQueue.main.async
                    {
                        
                        if self.playerCharacters == self.characterTaskCounter
                        {
                            print("DEBUG: LOADED ALL CHARACTERS SUCCESFULLY")
                            for (i, character) in self.currentUser!.userCharacters.enumerated()
                            {
                                self.getEmblemBackImg(characterIndex: i, path: character.characterEmblemBackPath, apiKey: self.apiKey)
                            }
                            
                        }
                }
                
            })
            task.resume()
        }
        //End of getCharacter
    }
    
    func getEmblemBackImg(characterIndex: Int, path: String, apiKey: String)
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
                
                //Grab the image from the data and store it in the variable.
                let emblemBackground = UIImage(data: data)!
                self.currentUser!.userCharacters[characterIndex].characterEmblemBack = emblemBackground
                
                
                print("DEBUG: Char Image load: \(characterIndex) success.")
                dispatch.leave()
                
                dispatch.notify(queue: DispatchQueue.main, execute: {
                    print("TESTER TASK DONE")
                    self.charImageTaskCounter += 1
                    
                    if self.playerCharacters == self.charImageTaskCounter
                    {
                        print("NOW CHECKING THE LOAD")
                        self.loadCheckCharImages()
                    }
                })
                
            })
            task.resume()
        }
        //End of getEmblemBackImg
    }
    
    
    

    //End of extension.
}

