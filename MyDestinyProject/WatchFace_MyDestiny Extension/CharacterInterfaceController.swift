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
                    if let data = replyData["characters"] as? [CharacterInfo] {
                        print("data grabbed")
                        self.characters.append(contentsOf: data)
                        //If the characters have been catched, then load the table view.
                        self.loadTableView()
                    }
                }
            }, errorHandler: { (error) -> Void in
                print(error.localizedDescription)
            })
        }
    }
    
    public func loadTableView() {
        tableView.setNumberOfRows(characters.count, withRowType: "RowController")
        
        for (i, _) in characters.enumerated() {
            if let rowController = tableView.rowController(at: i) as? RowController {
                
                //Set the image to the view.
                rowController.iv_characterEmblem.setImage(characters[i].characterEmblemBack)
            }
        }
    }
    
//    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
//
//        //Create message to send.
//        let myValues : [String: Any] = ["getKaijuDetail":rowIndex]
//        session?.sendMessage(myValues, replyHandler: {
//            replyData in
//
//            DispatchQueue.main.async {
//                if let data = replyData["kaijuDetails"] as? [String] {
//                    //Push to the next controller with the data retrieved.
//
//                    var kaijuDetails = [String]()
//                    kaijuDetails.append(data[0]) // name
//                    kaijuDetails.append(data[1]) // faction
//
//                    self.pushController(withName: "DetailInterfaceController", context: kaijuDetails)
//                }
//            }
//
//        }, errorHandler: { (error) -> Void in
//            print(error.localizedDescription)
//        })
//    }
    
}
