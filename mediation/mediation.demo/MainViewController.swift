//
//  MainViewController.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, PubnativeNetworkRequestDelegate {

    let DEFAULT_APP_TOKEN = "e3886645aabbf0d5c06f841a3e6d77fcc8f9de4469d538ab8a96cb507d0f2660"
    let PUBNATIVE_PLACEMENT = "pubnative_only";
    
    @IBOutlet weak var tableViewAds: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func requestTouchUpInside(sender: AnyObject) {
        
        let request:PubnativeNetworkRequest = PubnativeNetworkRequest();
        request.startWithAppToken(DEFAULT_APP_TOKEN, placementID: PUBNATIVE_PLACEMENT, delegate: self);
    }
    
    func pubnativeRequestDidStart(request: PubnativeNetworkRequest!) {
        print("pubnativeRequestDidStart");
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didFail error: NSError!) {
        print("pubnativeRequest:didFail:%@", error);
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didLoad ad: PubnativeAdModel!) {
        print("pubnativeRequest:didLoad:");
    }
    
}
