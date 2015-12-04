//
//  CellRequestModel.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

protocol CellRequestModelDelegate {
    func updateAdTableViewCell(indexPath: NSIndexPath)
}

class CellRequestModel: NSObject, PubnativeNetworkRequestDelegate {
    
    var networkRequest      : PubnativeNetworkRequest!
    var ad                  : PubnativeAdModel!
    var delegate            : CellRequestModelDelegate!
    var placementID         : String!
    var appToken            : String!
    var indexPath           : NSIndexPath!
    
    init(appToken: String, placementID: String) {
        self.networkRequest = PubnativeNetworkRequest()
        self.appToken = appToken
        self.placementID = placementID
    }
    
    /**
     Start the PubnativeNetworkRequest.
     
     @param indexPath An index path locating the row in tableView from where request is made.
     @param delegate To callback when the request is completed
     */

    func startRequest(indexPath: NSIndexPath, delegate:CellRequestModelDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        networkRequest.startRequestWithAppToken(appToken, placementID: placementID, delegate: self)
    }
    
    // MARK: PubnativeNetworkRequestDelegate Callback
    
    func pubnativeRequestDidStart(request: PubnativeNetworkRequest) {
        print("Request at cell \(indexPath.row): started")
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest, didLoad ad: PubnativeAdModel) {
        print("Request at cell \(indexPath.row): succeed")
        if (delegate != nil) {
            self.ad = ad
            delegate.updateAdTableViewCell(indexPath)
        }
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest, didFail error: NSError) {
        print("Request at cell \(indexPath.row): failed")
        if (delegate != nil) {
            self.ad = nil
            KSToastView.ks_showToast("\(error.domain)");
            delegate.updateAdTableViewCell(indexPath)
        }
    }
}
