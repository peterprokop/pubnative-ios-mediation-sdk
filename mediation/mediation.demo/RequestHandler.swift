//
//  RequestHandler.swift
//  mediation
//
//  Created by Mohit on 26/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

protocol UpdateRequestResponseDelegate {
    func updateAdTableViewCell(indexPath: NSIndexPath, ad: PubnativeAdModel)
    func updateAdTableViewCell(indexPath: NSIndexPath, error: NSError)
}

class RequestHandler: NSObject, PubnativeNetworkRequestDelegate {
    
    var cellRequest     : CellRequestModel!
    var indexPath       : NSIndexPath!
    var delegate        : UpdateRequestResponseDelegate!
    
    init(request: CellRequestModel, indexPath: NSIndexPath, delegate:UpdateRequestResponseDelegate) {
        self.cellRequest = request
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    func startRequest() {
        cellRequest.networkRequest.startRequestWithAppToken(cellRequest.appToken, placementID: cellRequest.placementID, delegate: self)
    }
    
    func pubnativeRequestDidStart(request: PubnativeNetworkRequest!) {
        print("NativeAdTableViewCell \(indexPath.row): pubnativeRequestDidStart")
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didLoad ad: PubnativeAdModel!) {
        if (delegate != nil) {
            print("NativeAdTableViewCell \(indexPath.row): pubnativeRequest:didLoad:")
            delegate.updateAdTableViewCell(indexPath, ad: ad)
        }
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didFail error: NSError!) {
        if (delegate != nil) {
            print("NativeAdTableViewCell \(indexPath.row): pubnativeRequest:didFail:")
            delegate.updateAdTableViewCell(indexPath, error: error)
        }
    }
}
