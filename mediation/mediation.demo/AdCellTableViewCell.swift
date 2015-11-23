//
//  AdCellTableViewCell.swift
//  mediation
//
//  Created by Mohit on 23/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class AdCellTableViewCell: UITableViewCell, PubnativeNetworkRequestDelegate {
    
    @IBOutlet weak var labelPlacementId         : UILabel!
    @IBOutlet weak var labelAdapterName         : UILabel!
    @IBOutlet weak var labelAdTitle             : UILabel!
    @IBOutlet weak var labelAdDescription       : UILabel!
    @IBOutlet weak var imageViewAdThumbnail     : UIImageView!
    @IBOutlet weak var imageViewAdBannerImage   : UIImageView!
    @IBOutlet weak var starRatingView           : FloatRatingView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    
    var request : CellRequestModel!
    
    @IBAction func onRequestTapped(sender: AnyObject) {
        cleanView()
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        request.request.startRequestWithAppToken(request.appToken, placementID: request.placementID, delegate: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cleanView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRequestModel(request : CellRequestModel) {
        self.request = request
        cleanView()
        renderAd()
    }
    
    func cleanView() {
        labelAdTitle.text = ""
        labelAdDescription.text = ""
        labelAdapterName.text = ""
        imageViewAdBannerImage.image = nil
        imageViewAdThumbnail.image = nil
        starRatingView.rating = 0
        starRatingView.hidden = true
        activityIndicator.hidden = true
    }
    
    func renderAd() {
        labelPlacementId.text = "Placement ID: " + request.placementID
        if (request.ad != nil) {
            labelAdapterName.text = "\(request.ad.dynamicType)".componentsSeparatedByString(".").last
            labelAdTitle.text = request.ad.title
            labelAdDescription.text = request.ad.description
            starRatingView.rating = request.ad.starRating
            starRatingView.hidden = false
            //TODO: Load thumb and large images and star tracking this
        }
    }
    
    func requestDidStart(request: PubnativeNetworkRequest!) {
        print("AdCellTableViewCell : requestDidStart")
    }
    
    func request(request: PubnativeNetworkRequest!, didLoad ad: PubnativeAdModel!) {
        print("AdCellTableViewCell : request:didLoad:")
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        self.request.ad = ad
        renderAd()
    }
    
    func request(request: PubnativeNetworkRequest!, didFail error: NSError!) {
        print("AdCellTableViewCell : request:didFail:")
        KSToastView.ks_showToast("\(error.domain)");
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        self.request.ad = nil
        cleanView()
    }
}
