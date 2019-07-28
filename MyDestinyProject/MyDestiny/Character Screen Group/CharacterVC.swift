//
//  CharacterVC.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit
import WatchConnectivity

class CharacterVC: AuthenticateVC, UITableViewDelegate, UITableViewDataSource, WCSessionDelegate {
    
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    //MARK: Outlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var currentUserCharVC: UserInfo?
    
    var characters = [CharacterInfo]()
    var selection = 0
    
    var itemTaskCounterCharVC = 0
    var itemTotalTaskCharVC = 0
    
    var itemImageTaskCounterCharVC = 0
    var itemImageTaskTotalCharVC = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session?.delegate = self
        session?.activate()
        
        //Disable scrolling.
        tableView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Sort the characters by highest light.
        characters.sort(by: {$0.characterLight > $1.characterLight})
    }
    
    //MARK: TableView Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Rows is based on the characters.
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let character = characters[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell") as! CharacterCell
        
        cell.emblemBackgroundImg.image = character.characterEmblemBack
        cell.classLabel.text = character.characterClass
        cell.lightLevelLabel.text = "\(character.characterLevel) \(character.characterLight)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //In here we will perform the loading of the items based on the selected character.
        selection = indexPath.row
        
        getCharacterCharVC(type: currentUserCharVC!.d2membershipType, membershipId: currentUserCharVC!.d2membershipId, characterId: characters[selection].characterId)
    }
    
    //Segue.
    override func  prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? ItemCollectionVC
        destination?.characters = characters
        destination?.characterSelected = selection
        destination?.apiKey = apiKey
    }
    
    //MARK: Watch session methods.
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //If the session becomes inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //If the session deactivates.
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if(message["getCharacters"] as? Bool) != nil{
                
                //key to send message over is "characters"
                
                //Need to figure out why i cant send characters class info over.
                var characterImages = [UIImage]()
                
                #warning("Payloads still cannot be delivered")
                    //Even with just sending one image, the payload still cannot be delivered, so I will need to figure out how to circumvent this.
                
                //Sending over the images instead.
                for character in self.characters {
                    characterImages.append(character.characterEmblemBack)
                }
            
                replyHandler( ["characters" : self.characters[0].characterEmblemBack] )
            }
        }
    }
    
    
}
