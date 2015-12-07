//
//  NativeAdTableViewCell.swift
//  mediation
//
//  Created by Mohit on 23/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class NativeAdTableViewCell: UITableViewCell, CellRequestModelDelegate {
    
    @IBOutlet weak var labelPlacementId         : UILabel!
    @IBOutlet weak var labelAdapterName         : UILabel!
    @IBOutlet weak var labelAdTitle             : UILabel!
    @IBOutlet weak var labelAdDescription       : UILabel!
    @IBOutlet weak var imageViewAdThumbnail     : UIImageView!
    @IBOutlet weak var imageViewAdBannerImage   : UIImageView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    @IBOutlet weak var buttonRequest            : UIButton!
    @IBOutlet weak var viewAdContainer          : UIView!
    @IBOutlet weak var starRatingView           : UIView!
    
    var indexPath                               : NSIndexPath!
    var cellRequest                             : CellRequestModel!
    var viewController                          : MainViewController!
    var ratingControl                           : AMRatingControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cleanView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func cleanView() {
        labelAdTitle.text = ""
        labelAdDescription.text = ""
        labelAdapterName.text = ""
        imageViewAdBannerImage.image = nil
        imageViewAdThumbnail.image = nil
        
        if (ratingControl == nil) {
            ratingControl = AMRatingControl.init(location: CGPointZero, emptyColor: UIColor.lightGrayColor(), solidColor: UIColor.orangeColor(), andMaxRating: 5)
            ratingControl.userInteractionEnabled = false
            starRatingView.addSubview(ratingControl)
        } else {
            ratingControl.rating = 0
        }
        
        starRatingView.hidden = true
        activityIndicator.hidden = true
        buttonRequest.userInteractionEnabled = true
    }
    
    /**
     Assocaite the CellRequestModel to the cell.
     
     @param request CellRequestModel that need to be associated
     @param indexPath An index path locating the row in tableView whose request need to be associated
     @param viewController ViewController needed for tracking the ad
     */
    func setRequestModel(request : CellRequestModel, indexPath : NSIndexPath, viewController: MainViewController) {
        self.cellRequest = request
        self.indexPath = indexPath
        self.viewController = viewController
        cleanView()
        renderAd()
    }
    
    func renderAd() {
        labelPlacementId.text = "Placement ID: " + cellRequest.placementID
        
        if (cellRequest.ad != nil) {
            labelAdapterName.text = String(cellRequest.ad!.dynamicType)
            labelAdTitle.text = cellRequest.ad.title
            labelAdDescription.text = cellRequest.ad.description
            ratingControl.rating = Int(cellRequest.ad.starRating)
            starRatingView.hidden = false
            imageViewAdThumbnail.hnk_setImageFromURL(NSURL(string: cellRequest.ad.iconURL), placeholder: nil)
            imageViewAdBannerImage.hnk_setImageFromURL(NSURL(string: cellRequest.ad.bannerURL), placeholder: nil)
            cellRequest.ad.startTrackingView(viewAdContainer, withViewController: viewController)
        }
    }
    
    // MARK: CellRequestModelDelegate Callback
    
    /**
    Will update the cell by reloading the tableview for the @param indexPath.
    
    @param indexPath An index path locating the row in tableView from where request is made.
    */
    func updateAdTableViewCell(indexPath: NSIndexPath) {
        let adsTableView : UITableView = self.superview?.superview as! UITableView
        adsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    // MARK: IBActions
    
    @IBAction func onRequestTapped(sender: AnyObject) {
        cleanView()
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        cellRequest.startRequest(indexPath, delegate: self)
    }
}
