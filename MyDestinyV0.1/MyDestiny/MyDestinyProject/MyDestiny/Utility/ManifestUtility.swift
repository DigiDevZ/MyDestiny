//
//  ManifestUtility.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 8/16/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation
import Zip

class ManifestUtility {

    //All of the functions that are being used to make manifest calls will be placed into here.
    
    //Will also need to place the contract variables in here.
    
    /**
     Start with the AuthenticateVC and then move down the list.
     */
    
    static var mManifestFileVersion: String?
    static var mManifestUpToDate: Bool = false
    static var mManifestExists: Bool = false
    
    static var mManifestPath: String?
    
    
    /**
     checkManifestExists
     This function will check to see if the manifest is already downloaded and stored on the device.
     If the manifest is downloaded, it will check for any update to the manifest.
     If the manifest is not downloaded it will download the manifest.
    */
    
    static func checkManifestExists() {
        getManifestPath()
        if(mManifestPath != nil) {
            let fileManager = FileManager()
            if fileManager.fileExists(atPath: mManifestPath!) {
                checkManifestForUpdate()
            } else {
                retrieveManifestVersion(manifestExists: false)
            }
        }else {
            return
        }
    }
    
    /**
     checkManifestForUpdate
     This function will retrieve the manifest name from storage, and store it for checking against the API manifest name.
     */
    
    static func checkManifestForUpdate() {
        if(mManifestPath == nil) {
            //If the path is invalid then return from the method immediately.
            return
        }
    
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: mManifestPath!) {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: mManifestPath!)
                let manifestFile = contents[0]
                
                mManifestFileVersion = manifestFile
                retrieveManifestVersion(manifestExists: true)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /**
     retrieveManifestVersion
     This function will check the manifest version/name that is located in the Destiny API.
     
     Takes in the parameter (manifestExists: Bool)
     -- If this parameter is TRUE this method will check to see if the manifest versions are different,
        if they are same, the manifest is up to date and nothing else needs to happen.
     -- If this parameter is FALSE, this method will download the manifest after retrieving its path.
     */
    
    static func retrieveManifestVersion(manifestExists: Bool) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/Platform/Destiny2/Manifest/") {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(APIUtility.API_KEY, forHTTPHeaderField: "X-API-KEY")
            
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
                
                do {
                    //De-Serialize data object
                    //MARK: First level object is a dictionary.
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        //Parse Data
                        //Sources is a dictionary.
                        guard let response = jsonObject["Response"] as? [String: Any]
                            else { return }
                        
                        if let manifest = response["mobileWorldContentPaths"] as? [String: Any] {
                            if let enManifestApiPath = manifest["en"] as? String {
                            
                                let array = enManifestApiPath.split(separator: "/")
                                let enManifestVersion = array[4].description
                                
                                dispatch.leave()
                                
                    
                                dispatch.notify(queue: DispatchQueue.main, execute: {
                                    
                                    if(manifestExists) {
                                        if(mManifestFileVersion != nil && mManifestFileVersion == enManifestVersion) {
                                            print("Manifest up to date.")
                                            //If up to date, set manifestUpToDate to true and then continue down the chain.
                                            mManifestUpToDate = true
                                        }else if(mManifestFileVersion != nil && mManifestFileVersion != enManifestVersion) {
                                            print("Manifest not up to date.")
                                            //If not up to date, update the manifest and load the rest of the data.
                                            mManifestUpToDate = false
                                            downloadManifest(manifestPath: enManifestApiPath)
                                        }
                                    }else {
                                        downloadManifest(manifestPath: enManifestApiPath)
                                    }
                                })
                            }
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
    }
    
    /**
     downloadManifest
     This function will download the manifest located at the manifestPath, and then unzip the contents into the devices storage.
     
     Takes in the parameter (manifestPath: String)
     -- This parameter is the location of the most up to date manifest stored in the Destiny API.
     */
    
    static func downloadManifest(manifestPath: String)
    {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let validURL = URL(string: "https://www.bungie.net/" + manifestPath)
        {
            var request = URLRequest(url: validURL)
            request.httpMethod = "GET"
            request.addValue(APIUtility.API_KEY, forHTTPHeaderField: "X-API-KEY")
            
            let task = session.downloadTask(with: request, completionHandler: {(opt_data, opt_response, opt_error) in
                
                //Bail Out on error
                if opt_error != nil { return }
                
                //Check the response, statusCode, and data
                guard let response = opt_response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = opt_data
                    else { print("Database download failed."); return }
                
                let fileManager = FileManager.default
                do {
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileURL = documentDirectory.appendingPathComponent("MyDestinyManifest").appendingPathExtension("zip")
                    
                    //Store the data into the fileUrl.
                    _ = try fileManager.replaceItemAt(fileURL, withItemAt: data)
                    
                    //Now unzip the file.
                    do {
                        let fileUnzippedPlacementUrl = try Zip.quickUnzipFile(fileURL)
                        print("DEBUG: file stored at: " + fileUnzippedPlacementUrl.absoluteString)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                catch (let writeError) {
                    print("Error creating a file \(writeError)")
                }
            })
            task.resume()
        }
    }
    
    
    /**
     getManifestPath
     This function will get the storage path of where the manifest is going to be saved to.
     */

    static func getManifestPath() {
        //This is how to get the document path for a device.
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            mManifestPath = documentsPath + "/MyDestinyManifest"
        }
    }
    
}
