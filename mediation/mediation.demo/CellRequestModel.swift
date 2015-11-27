//
//  CellRequestModel.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class CellRequestModel: NSObject {
    
    var networkRequest      : PubnativeNetworkRequest!
    var ad                  : PubnativeAdModel!
    var placementID         : String!
    var appToken            : String!
    var isRequestLoading    : Bool!
    
    init(appToken: String, placementID: String) {
        self.networkRequest = PubnativeNetworkRequest()
        self.appToken = appToken
        self.placementID = placementID
        self.isRequestLoading = false
    }
}
