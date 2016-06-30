//
//  NativeTableViewCell.swift
//  mediation
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation

class NativeTableViewCell: UITableViewCell, PubnativeNetworkRequestDelegate {
    
    // MARK: Properties

    private var model : PubnativeAdModel!
    
    var placementName : String! {
        
        didSet {
            
            placement.text = "Placement ID: " + placementName
        }
    }
    
    var controller : UITableViewController!
    
    // MARK: OUTLETS

    @IBOutlet weak var placement: UILabel!
    @IBOutlet weak var adapter: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // Ad 
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adBanner: UIImageView!
    @IBOutlet weak var adIcon: UIImageView!
    @IBOutlet weak var adTitle: UILabel!
    @IBOutlet weak var adDescription: UILabel!
    
    // MARK: ACTIONS
    
    @IBAction func requestTouchUpInside(sender: AnyObject){
        
        print("REQUEST PUSHED")
        adView.hidden = true
        adapter.text = ""
        loader.startAnimating()
        let request:PubnativeNetworkRequest = PubnativeNetworkRequest();
        request.startWithAppToken(Settings.appToken, placementName:placementName, delegate:self);
    }
    
    // MARK: -
    // MARK: CALLBACKS
    // MARK: -
    
    // MARK: PubnativeNetworkRequestDelegate
    
    func pubnativeRequestDidStart(request: PubnativeNetworkRequest!) {
        print("pubnativeRequestDidStart");
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didFail error: NSError!) {
        print("pubnativeRequest:didFail:%@", error);
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didLoad ad: PubnativeAdModel!) {
        print("pubnativeRequest:didLoad:");
        
        model = ad
        if(model != nil) {
            adapter.text = String(model)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let iconData:NSData = NSData(contentsOfURL: NSURL(string:ad.iconURL)!)!;
            let bannerData:NSData = NSData(contentsOfURL: NSURL(string:ad.bannerURL)!)!;
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let iconImage:UIImage = UIImage(data: iconData)!;
                let bannerImage:UIImage = UIImage(data: bannerData)!;
                
                self.adTitle.text = ad.title;
                self.adDescription.text = ad.description;
                self.adBanner.image = bannerImage;
                self.adIcon.image = iconImage;
                
                self.loader.stopAnimating()
                self.adView.hidden = false;
            }
        }
        
        model?.startTrackingView(self, withViewController:self.controller);
    }
}