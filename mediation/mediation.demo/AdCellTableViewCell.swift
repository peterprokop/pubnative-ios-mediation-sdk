//
//  AdCellTableViewCell.swift
//  mediation
//
//  Created by Mohit on 23/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

protocol StartRequestDelegate {
    func startRequest(indexPath: NSIndexPath)
}

class AdCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelPlacementId         : UILabel!
    @IBOutlet weak var labelAdapterName         : UILabel!
    @IBOutlet weak var labelAdTitle             : UILabel!
    @IBOutlet weak var labelAdDescription       : UILabel!
    @IBOutlet weak var imageViewAdThumbnail     : UIImageView!
    @IBOutlet weak var imageViewAdBannerImage   : UIImageView!
    @IBOutlet weak var starRatingView           : FloatRatingView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    @IBOutlet weak var buttonRequest            : UIButton!
    
    var delegate            : StartRequestDelegate!
    var cellRequest         : CellRequestModel!
    var indexPath           : NSIndexPath!
    
    @IBAction func onRequestTapped(sender: AnyObject) {
        cleanView()
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        delegate.startRequest(indexPath)
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
    
    func setRequestModel(request : CellRequestModel, indexPath : NSIndexPath) {
        self.cellRequest = request
        self.indexPath = indexPath
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
            //TODO: Load thumb and large images and star tracking this
        }
    }
}
