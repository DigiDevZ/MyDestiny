//
//  ItemCollectionVC.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/27/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "itemCell"

class ItemCollectionVC: UICollectionViewController {
    
    @IBOutlet var inventoryView: UICollectionView!
    
    //MARK: Datasource
    var apiKey = ""
    
    var characterSelected = -1
    var characters = [CharacterInfo]()
    
    //Weapon buckets
    var kineticBucket = [ItemInfo]()
    var energyBucket = [ItemInfo]()
    var powerBucket = [ItemInfo]()
    
    //Armor buckets
    var helmBucket = [ItemInfo]()
    var gauntletBucket = [ItemInfo]()
    var chestBucket = [ItemInfo]()
    var legBucket = [ItemInfo]()
    var classBucket = [ItemInfo]()
    
    //Inventory array
    var characterInventory = [[ItemInfo]()]
    
    //MARK: Items to send to next screen
    var itemName = ""
    var itemImage = UIImage()
    var itemId = ""
    var itemHash = 0
    var itemDescription = "" 
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.title = characters[characterSelected].characterClass + " " + characters[characterSelected].characterLight.description
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        //Sort the bucket arrays.
        for item in characters[characterSelected].characterItemInventory
        {
            switch item.itemType
            {
            case "Kinetic":
                kineticBucket.append(item)
            case "Energy":
                energyBucket.append(item)
            case "Power":
                powerBucket.append(item)
            case "Helm":
                helmBucket.append(item)
            case "Gauntlet":
                gauntletBucket.append(item)
            case "Chest":
                chestBucket.append(item)
            case "Leg":
                legBucket.append(item)
            case "Class":
                classBucket.append(item)
            default:
                print("oops")
            }
        }
        //Remove the inventory to get a clean slate and make sure there are no duplications.
        characterInventory.removeAll()
        
        //Insert all the buckets into the inventory array for the data source.
        characterInventory.append(kineticBucket)
        characterInventory.append(energyBucket)
        characterInventory.append(powerBucket)
        
        characterInventory.append(helmBucket)
        characterInventory.append(gauntletBucket)
        characterInventory.append(chestBucket)
        characterInventory.append(legBucket)
        characterInventory.append(classBucket)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        //Sections are based off of the buckets on a character, so 8.
        return characterInventory.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //Number of items in one bucket will be no more than 9.
        return characterInventory[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        // Configure the cell
        cell.imageView.image = characterInventory[indexPath.section][indexPath.row].itemIcon
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    //This function sets the sections label.
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        
        switch kind
        {
        case UICollectionView.elementKindSectionHeader:
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(ItemHeaderView.self)", for: indexPath) as? ItemHeaderView
                else {fatalError("Invalid view type")}
            
            var sectionText = ""
            
            switch indexPath.section
            {
            case 0:
                sectionText = "Kinetic"
            case 1:
                sectionText = "Energy"
            case 2:
                sectionText = "Power"
            case 3:
                sectionText = "Helm"
            case 4:
                sectionText = "Gauntlet"
            case 5:
                sectionText = "Chest"
            case 6:
                sectionText = "Leg"
            case 7:
                sectionText = "Class"
            default:
                print("Section N/A")
            }
            
            headerView.sectionLabel.text = sectionText
            return headerView
            
        default:
            assert(false, "Invalid element type")
        }
        
    }
    
    //This function will prepare a segue for the selected item, and start gathering the items information.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        itemName = characterInventory[indexPath.section][indexPath.row].itemName
        itemImage = characterInventory[indexPath.section][indexPath.row].itemIcon
        itemId = characterInventory[indexPath.section][indexPath.row].itemInstance
        itemHash = characterInventory[indexPath.section][indexPath.row].itemHash
        itemDescription = characterInventory[indexPath.section][indexPath.row].itemDescription
        
        performSegue(withIdentifier: "segueToItemScreen", sender: self)
        print("Selected item \(indexPath.row)")
    }
    
    //This function will perform the segue.
    override func  prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? ItemVC
        destination?.characters = characters
        destination?.apiKey = apiKey
        destination?.itemName = itemName
        destination?.itemImage = itemImage
        destination?.itemId = itemId
        destination?.itemHash = itemHash
        destination?.senderCharacterId = characters[characterSelected].characterId
        destination?.itemDescription = itemDescription
        
    }
    
    @IBAction func unwindToItemCollectionVC(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    
}
