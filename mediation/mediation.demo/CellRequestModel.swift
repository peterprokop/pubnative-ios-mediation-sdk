//
//  CellRequestModel.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class CellRequestModel: NSObject {
    var request     : PubnativeNetworkRequest!
    var ad          : PubnativeAdModel!
    var placementID : String!
    var appToken    : String!
    
    init(appToken: String, placementID: String) {
        request = PubnativeNetworkRequest()
        self.appToken = appToken
        self.placementID = placementID        
    }
}
