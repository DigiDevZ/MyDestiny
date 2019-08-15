//
//  ViewController.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import UIKit
//For Authenticating the user.
import OAuthSwift
//For saving the access and refresh tokens.
import SwiftKeychainWrapper
//For searching through the destiny manifest.
import SQLite
//For unzipping the destiny manifest when I retrieve it.
import Zip

class AuthenticateVC: UIViewController {
    
    //MARK: Variables
    var oauthswift: OAuth2Swift?
    
    var currentUser: UserInfo?
    
    let apiKey = "66c4a62bb86b40abb64894ba96676e0b"
    
    let rootPathImages = "https://www.bungie.net/"
    
    //MARK: Load Variables
    var loadGetCurrentUser = false
    var loadSearchProfile = false 
    
    var playerCharacters = -1
    
    //Will use these variable for streamlining the download process.
    //3
    var taskCounter = 0
    //Dependent on total items user has overall.
    var itemTotalTask = 0
    var itemTaskCounter = 0
    var itemImageTaskCounter = 0
    var itemImageTaskTotal = 0
    //Dependent on number of characters user has.
    var characterTaskCounter = 0
    var charImageTaskCounter = 0
    
    //This is for testing if the manifest is available.
    var manifestLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var authenticateButton: UIButton!
    
    @IBAction func authenticateTapped(_ sender: Any)
    {
        authenticateButton.isEnabled = false
        authenticateButton.isHidden = true 
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        
        //Randomize this for every client.
        let clientState = "0101"
        
        //Fill the oauthswift with the necessary info.
        oauthswift = OAuth2Swift(
            consumerKey:    "27050",//ClientID provided by Bungie.
            consumerSecret: "R0Wka5em2tU6mPZTrFRtaLfFPjtCmtXe3kdSXfDJP1Y",//Client secret provided by Bungie.
            authorizeUrl:   "https://www.bungie.net/en/OAuth/Authorize?client_id=27050&response_type=code&state=\(clientState)",
            accessTokenUrl: "https://www.bungie.net/platform/app/oauth/token/",
            responseType:   "code"
        )
        
        oauthswift!.allowMissingStateCheck = true
        
        //Prepare for a new view controller to appear.
        oauthswift!.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
        
        //Main magic happens here.
        //For scope it is said to omit it, so I am not putting anything in it.
        oauthswift!.authorize(withCallbackURL: URL(string: "MyDestinyVaultAppleiOS://"), scope: "", state: clientState, success: {
            (credential, response, parameters) in
            //Success
            
            //Capturing the authorization information and storing the vitals into the keychain.
            let userAccessToken = parameters["access_token"] as! String
            let userAccessTokenExpire = parameters["expires_in"] as! Int
            let userRefreshToken = parameters["refresh_token"] as! String
            let userRefreshTokenExpire = parameters["refresh_expires_in"] as! Int
            let userMembershipID = parameters["membership_id"] as! String
            let userTokenType = parameters["token_type"] as! String
            
            print("ACCESS TOKEN: " + userAccessToken)
            
            //Keychain saving started.
            let saveSuccesful: Bool = KeychainWrapper.standard.set(userRefreshToken, forKey: "d2MyDestinyRefreshToken")
            
            let _: Bool = KeychainWrapper.standard.set(userAccessToken, forKey: "d2MyDestinyAccessToken")
            
            print("DEBUG: Saving tokens to keychain: \(saveSuccesful)")
            
            let retrievedString: String? = KeychainWrapper.standard.string(forKey: "d2MyDestinyRefreshToken")
            
            print("DEBUG: retrieving tokens from keychain: \(retrievedString ?? "No refresh token saved.")")
            //Keychain saving done.
            
            //Create the currentUser.
            self.currentUser = UserInfo(accessToken: userAccessToken, accessTokenExpire: userAccessTokenExpire, refreshToken: userRefreshToken, refreshTokenExpiration: userRefreshTokenExpire, membershipID: userMembershipID, tokenType: userTokenType)
            
            //Begin the chain of loading in the users information.
            self.loadUserInfo(currentUser: self.currentUser!)
            
        }, failure: { (error) in
            //Failure
        })
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCharacterScreen" {
            
            //Stop the loading indicator
            loadingIndicator.stopAnimating()
            
            //Since I am seguing through a navigation controller, I need to make my first destination the NavViewController.
            if let navVC = segue.destination as? UINavigationController
            {
                //Second destination is the sources/categories screen.
                if let destination = navVC.viewControllers.first as? CharacterVC
                {
                    destination.characters = self.currentUser!.userCharacters
                    destination.currentUserCharVC = self.currentUser
                }
            }
        }
    }
    
    //MARK: Load functions.
    //This function will gather all the information on the user and their characters and once it is done it will check, and then load the next view with a segue.
    func loadUserInfo(currentUser: UserInfo)
    {
        getCurrentBungieUser(accessToken: currentUser.userAccessToken)
    }
    
    
    func loadCheck()
    {
        self.performSegue(withIdentifier: "segueToCharacterScreen", sender: self)
    }
    
    func loadCheckCharImages()
    {
        if playerCharacters == charImageTaskCounter
        {
            downloadDB()
        }
    }
    
    //MARK: Database downloads.
    func downloadDB()
    {
        //Put the check for the folder here.
        //MyDestinyManifest <- folders name
        
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: getDocumentDirectoryPath() + "/MyDestinyManifest") {
            //If the file already exists return a bool.
            print("File already exists")
            manifestLoaded = true
            self.loadCheck()
        } else {
            //File space available and app can download the rest of the manifest.
            print("File space available")
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/Manifest/")
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
                            
                            if let manifest = response["mobileWorldContentPaths"] as? [String: Any]
                            {
                                if let enManifest = manifest["en"] as? String
                                {
                                    
                                    dispatch.leave()
                                    
                                    dispatch.notify(queue: DispatchQueue.main, execute: {
                                        
                                        self.downloadManifest(manifestPath: enManifest)
                                        
                                    })
                                }
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
        }
        //End of test function
    }
    
    func downloadManifest(manifestPath: String)
    {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/" + manifestPath)
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            
            let task = session.downloadTask(with: request, completionHandler: {(opt_data, opt_response, opt_error) in
                
                //Bail Out on error
                if opt_error != nil { return }
                
                //Check the response, statusCode, and data
                guard let response = opt_response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = opt_data
                    else { print("Database download failed."); return }
                
                let fileManager = FileManager.default
                do
                {
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileURL = documentDirectory.appendingPathComponent("MyDestinyManifest").appendingPathExtension("zip")
                    
                    try fileManager.copyItem(at: data, to: fileURL)
                    
                    //Now unzip the file.
                    do {
                        
                        _ = try Zip.quickUnzipFile(fileURL)
                        self.manifestLoaded = true
                        self.loadCheck()
                        
                    } catch {
                        print("Unzipping failed.")
                    }
                    
                    
                }
                    
                catch (let writeError) {
                    print("Error creating a file \(writeError)")
                    
                }
            })
            task.resume()
        }
        //End of function
    }
    
    
    //MARK: Misc. functions
    
    //This function will return the directory path of the device.
    func getDocumentDirectoryPath() -> String
    {
        var returnString = ""
        
        //This is how to get the document path for a device.
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path
        {
            returnString = documentsPath
        }
        
        return returnString
    }
    
    //This function will encode a string, using only gamertags for query.
    func encodeGamerTagForQuery(gamerTag: String) -> String?
    {
        let encodedGamerTag = gamerTag.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        return encodedGamerTag
    }
    
    //End of VC.
}

