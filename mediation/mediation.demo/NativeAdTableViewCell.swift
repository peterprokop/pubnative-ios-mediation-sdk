//
//  NativeAdTableViewCell.swift
//  mediation
//
//  Created by Mohit on 23/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class NativeAdTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelPlacementId         : UILabel!
    @IBOutlet weak var labelAdapterName         : UILabel!
    @IBOutlet weak var labelAdTitle             : UILabel!
    @IBOutlet weak var labelAdDescription       : UILabel!
    @IBOutlet weak var imageViewAdThumbnail     : UIImageView!
    @IBOutlet weak var imageViewAdBannerImage   : UIImageView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    @IBOutlet weak var buttonRequest            : UIButton!
    @IBOutlet weak var viewadContainer          : UIView!
    @IBOutlet weak var starRatingView           : FloatRatingView!
    
    var indexPath                               : NSIndexPath!
    var cellRequest                             : CellRequestModel!
    var viewController                          : MainViewController!
    
    @IBAction func onRequestTapped(sender: AnyObject) {
        cleanView()
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        cellRequest.startRequest(indexPath, delegate: viewController)
        if (cellRequest.isRequestLoading == true) {
            buttonRequest.userInteractionEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cleanView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setRequestModel(request : CellRequestModel, indexPath : NSIndexPath, viewController: MainViewController) {
        self.cellRequest = request
        self.indexPath = indexPath
        self.viewController = viewController
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
        buttonRequest.userInteractionEnabled = true
    }
    
    func renderAd() {
        labelPlacementId.text = "Placement ID: " + cellRequest.placementID
        if (cellRequest.isRequestLoading == true) {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }
        if (cellRequest.ad != nil) {
            labelAdapterName.text = String(cellRequest.ad!.dynamicType)
            labelAdTitle.text = cellRequest.ad.title
            labelAdDescription.text = cellRequest.ad.description
            starRatingView.rating = cellRequest.ad.starRating
            starRatingView.hidden = false
            imageViewAdThumbnail.hnk_setImageFromURL(NSURL(string: cellRequest.ad.iconURL), placeholder: nil)
            imageViewAdBannerImage.hnk_setImageFromURL(NSURL(string: cellRequest.ad.bannerURL), placeholder: nil)
            cellRequest.ad.startTrackingView(viewadContainer, withViewController: viewController)
        }
    }
}
