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
    
    func requestDidStart(request: PubnativeNetworkRequest!) {
        print("NativeAdTableViewCell \(indexPath.row): requestDidStart")
    }
    
    func request(request: PubnativeNetworkRequest!, didLoad ad: PubnativeAdModel!) {
        if (delegate != nil) {
            print("NativeAdTableViewCell \(indexPath.row): request:didLoad:")
            delegate.updateAdTableViewCell(indexPath, ad: ad)
        }
    }
    
    func request(request: PubnativeNetworkRequest!, didFail error: NSError!) {
        if (delegate != nil) {
            print("NativeAdTableViewCell \(indexPath.row): request:didFail:")
            delegate.updateAdTableViewCell(indexPath, error: error)
        }
    }
}
