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
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adBanner: UIImageView!
    @IBOutlet weak var adIcon: UIImageView!
    @IBOutlet weak var adTitle: UILabel!
    @IBOutlet weak var adCTA: UIButton!
    @IBOutlet weak var adLoading: UIActivityIndicatorView!
    
    var currentAd : PubnativeAdModel!;
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideAdView();
        hideLoading();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: MainViewController
    
    func showLoading(){
        self.adLoading.hidden = false;
        self.adLoading.startAnimating();
    }
    
    func hideLoading(){
        adLoading.stopAnimating();
        adLoading.hidden = true;
    }
    
    func hideAdView() {
        adView.hidden = true;
    }
    
    func showAdView() {
        hideLoading();
        adView.alpha = 0;
        adView.hidden = false;
        UIView.animateWithDuration(0.25) { 
            self.adView.alpha=1;
        }
    }
    
    // MARK: IBActions
    
    @IBAction func requestTouchUpInside(sender: AnyObject) {
        
        hideAdView();
        showLoading();
        
        currentAd?.stopTracking();
        
        let request:PubnativeNetworkRequest = PubnativeNetworkRequest();
        request.startWithAppToken(DEFAULT_APP_TOKEN, placementID: PUBNATIVE_PLACEMENT, delegate: self);
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
        
        currentAd = ad
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let iconData:NSData = NSData(contentsOfURL: NSURL(string:ad.iconURL)!)!;
            let bannerData:NSData = NSData(contentsOfURL: NSURL(string:ad.bannerURL)!)!;
            
            dispatch_async(dispatch_get_main_queue()) {
        
                let iconImage:UIImage = UIImage(data: iconData)!;
                let bannerImage:UIImage = UIImage(data: bannerData)!;
                
                self.adTitle.text = ad.title;
                self.adCTA.setTitle(ad.callToAction, forState:UIControlState.Normal);
                self.adBanner.image = bannerImage;
                self.adIcon.image = iconImage;
                
                self.showAdView();
            }
        }
        
        currentAd?.startTrackingView(self.adView, withViewController: self);
    }
    
}
