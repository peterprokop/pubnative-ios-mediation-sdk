//
//  MainViewController.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, StartRequestDelegate, UpdateRequestResponseDelegate {
    
    let APP_TOKEN                           = "7c26af3aa5f6c0a4ab9f4414787215f3bdd004f80b1b358e72c3137c94f5033c"
    var cellRequests : [CellRequestModel]   = []
    
    @IBOutlet weak var tableViewAds: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MainViewController"
        
        // Store test crediantials
        let placements = ["facebook_only"]
        PubnativeTestCrediantials.setStoredPlacements(placements)
        PubnativeTestCrediantials.setStoredApptoken(APP_TOKEN)
        for placementID in placements {
            cellRequests.append(CellRequestModel.init(appToken: APP_TOKEN, placementID: placementID))
        }
        tableViewAds.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayPlacementsList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Set Up
    func displayPlacementsList() {
        let appToken : String? = PubnativeTestCrediantials.storedApptoken()
        var placements : [String]? = PubnativeTestCrediantials.storedPlacements()
        if (appToken != nil && appToken?.characters.count > 0 &&
            placements != nil && placements?.count > 0) {
                var newRequests : [CellRequestModel] = []
                for request in cellRequests {
                    var isOldRequest    : Bool  = false
                    var removeAtIndex   : Int   = 0
                    for index in 0..<placements!.count {
                        let placement = placements![index]
                        if placement == request.placementID {
                            isOldRequest = true
                            removeAtIndex = index
                            break
                        }
                    }
                    
                    if (isOldRequest) {
                        newRequests.append(request)
                        placements?.removeAtIndex(removeAtIndex)
                    }
                }
                for placementID : String in placements! {
                    newRequests.append(CellRequestModel.init(appToken: APP_TOKEN, placementID: placementID))
                }
                cellRequests = newRequests
                tableViewAds.reloadData()
        }
    }
    
    // MARK: StartRequestDelegate Callbacks
    func startRequest(indexPath: NSIndexPath) {
        if (indexPath.row < cellRequests.count) {
            let cellRequest : CellRequestModel = cellRequests[indexPath.row]
            cellRequest.isRequestLoading = true
            let requestHandler : RequestHandler = RequestHandler(request: cellRequest, indexPath: indexPath, delegate: self)
            requestHandler.startRequest()
        }
    }
    
    // MARK: UpdateRequestResponseDelegate Callbacks
    func updateAdTableViewCell(indexPath: NSIndexPath, ad: PubnativeAdModel) {
        let cellRequest : CellRequestModel = cellRequests[indexPath.row]
        cellRequest.isRequestLoading = false
        cellRequest.ad = ad
        cellRequests[indexPath.row] = cellRequest
        tableViewAds.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func updateAdTableViewCell(indexPath: NSIndexPath, error: NSError) {
        let cellRequest : CellRequestModel = cellRequests[indexPath.row]
        cellRequest.isRequestLoading = false
        cellRequest.ad = nil
        cellRequests[indexPath.row] = cellRequest
        tableViewAds.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        KSToastView.ks_showToast("\(error.domain)");
    }
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NativeAdTableViewCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdTableViewCell
        if indexPath.row < cellRequests.count {
            cell.setRequestModel(cellRequests[indexPath.row], indexPath:indexPath, viewController: self);
        }
        cell.delegate = self
        return cell
    }
}
