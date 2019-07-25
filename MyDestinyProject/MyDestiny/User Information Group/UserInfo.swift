//
//  UserInfo.swift
//  MyDestiny
//
//  Created by Zakarie Ortiz on 5/23/19.
//  Copyright © 2019 Zakarie Ortiz. All rights reserved.
//

import Foundation

class UserInfo {
    
    //Stored
    var userAccessToken = ""
    var userAccessTokenExpiration = 0
    var userRefreshToken = ""
    var userRefreshTokenExpiration = 0
    var userMembershipId = ""
    var userTokenType = ""
    
    var d2membershipId = ""
    var d2membershipType = ""
    
    //Store any of the gamertags associated with the users account.
    var xboxDisplayName = ""
    var psnDisplayName = ""
    var blizzDisplayName = ""

    var characterIds = [String]()
    var userCharacters = [CharacterInfo]()
    
    
    //Computed
    var playerGamertags: [String]
    {
        var returnArray = [String]()
        
        if xboxDisplayName != ""
        {
            returnArray.append(xboxDisplayName)
        }
        
        if psnDisplayName != ""
        {
            returnArray.append(psnDisplayName)
        }
        
        if blizzDisplayName != ""
        {
            returnArray.append(blizzDisplayName)
        }
        
        return returnArray
    }
    
    //Inits
    init (accessToken: String, accessTokenExpire: Int, refreshToken: String, refreshTokenExpiration: Int, membershipID: String, tokenType: String)
    {
        self.userAccessToken = accessToken
        self.userAccessTokenExpiration = accessTokenExpire
        self.userRefreshToken = refreshToken
        self.userRefreshTokenExpiration = refreshTokenExpiration
        self.userMembershipId = membershipID
        self.userTokenType = tokenType
    }
}

