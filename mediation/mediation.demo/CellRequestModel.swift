//
//  CellRequestModel.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

protocol UpdateRequestResponseDelegate {
    func updateAdTableViewCell(indexPath: NSIndexPath)
}

class CellRequestModel: NSObject, PubnativeNetworkRequestDelegate {
    
    var networkRequest      : PubnativeNetworkRequest!
    var ad                  : PubnativeAdModel!
    var delegate            : UpdateRequestResponseDelegate!
    var placementID         : String!
    var appToken            : String!
    var isRequestLoading    : Bool!
    var indexPath           : NSIndexPath!
    
    init(appToken: String, placementID: String) {
        self.networkRequest = PubnativeNetworkRequest()
        self.appToken = appToken
        self.placementID = placementID
        self.isRequestLoading = false
    }
    
    func startRequest(indexPath: NSIndexPath, delegate:UpdateRequestResponseDelegate) {
        self.isRequestLoading = true
        self.indexPath = indexPath
        self.delegate = delegate
        networkRequest.startRequestWithAppToken(appToken, placementID: placementID, delegate: self)
    }
    
    func pubnativeRequestDidStart(request: PubnativeNetworkRequest) {
        print("Request at cell \(indexPath.row): started")
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest, didLoad ad: PubnativeAdModel) {
        print("Request at cell \(indexPath.row): succeed")
        if (delegate != nil) {
            self.ad = ad
            self.isRequestLoading = false            
            delegate.updateAdTableViewCell(indexPath)
        }
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest, didFail error: NSError) {
        print("Request at cell \(indexPath.row): failed")
        if (delegate != nil) {
            self.ad = nil
            self.isRequestLoading = false
            KSToastView.ks_showToast("\(error.domain)");
            delegate.updateAdTableViewCell(indexPath)
        }
    }
}
