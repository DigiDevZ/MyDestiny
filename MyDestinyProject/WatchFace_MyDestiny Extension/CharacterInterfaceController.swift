//
//  CharacterInterfaceController.swift
//  WatchFace_MyDestiny Extension
//
//  Created by Zakarie Ortiz on 7/24/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class CharacterInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("Connected and Activated")
        getCharacters()
    }
    

    //Session var
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    var characters = [CharacterInfo]()
    var characterImagePathArray = [String]()
    var characterImages = [UIImage]()
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    override init() {
        super.init()
        
    }
    
    // MARK: Lifecycle callbacks
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        session?.delegate = self
        session?.activate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    
    
    // MARK: Custom methods
    
    public func getCharacters() {
        let myValues : [String:Any] = ["getCharacters":true]
        
        if let session = session, session.isReachable {
            
            print("retrieving characters")
            session.sendMessage(myValues, replyHandler: {
                replyData in
                
                DispatchQueue.main.async {
                    //MARK: I think this class cannot sent correctly as a payload, will be fixing this soon.
                    if let data = replyData["characterImagePaths"] as? [String] {
                        print("data grabbed")
                        
                        self.characterImagePathArray.append(contentsOf: data)
                        //If the characters have been catched, then load the table view.
                        for path in self.characterImagePathArray {
                            self.getEmblemBackImage(path: path)
                        }
                    }
                }
            }, errorHandler: { (error) -> Void in
                print(error.localizedDescription)
            })
        }
    }
    
    public func loadTableView() {
        tableView.setNumberOfRows(characterImagePathArray.count, withRowType: "RowController")
        
        //For loop the function.
        for (i,_) in characterImagePathArray.enumerated() {
            if let rowController = tableView.rowController(at: i) as? RowController {
                
                //Set the image to the view.
                rowController.iv_characterEmblem.setImage(characterImages[i])
            }
        }
        
    }
    
    
    func getEmblemBackImage(path: String)
    {
        let rootPath = "https://www.bungie.net"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if let validURL = URL(string: rootPath + path)
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue("66c4a62bb86b40abb64894ba96676e0b", forHTTPHeaderField: "X-API-KEY")
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
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
                self.characterImages.append(emblemBackground)
                dispatch.leave()
                
                dispatch.notify(queue: DispatchQueue.main, execute: {
                    if(self.characterImages.count == 3) {
                        print("loading table view")
                        self.loadTableView()
                    }
                    
                })
                
            })
            task.resume()
        }
        //End of getEmblemBackImg
    }
    
}
