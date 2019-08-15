//
//  CharacterVC.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit

class CharacterVC: AuthenticateVC, UITableViewDelegate, UITableViewDataSource {
    
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
    
    
    
}
