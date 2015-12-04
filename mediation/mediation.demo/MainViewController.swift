//
//  MainViewController.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource {
    
    let APP_TOKEN                           = "7c26af3aa5f6c0a4ab9f4414787215f3bdd004f80b1b358e72c3137c94f5033c"
    var cellRequests : [CellRequestModel]   = []
    
    @IBOutlet weak var tableViewAds: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title at the navigation bar on top
        navigationItem.title = "MainViewController"
        
        // Store test crediantials
        let placements = ["facebook_only"]
        PubnativeTestCrediantials.setStoredPlacements(placements)
        PubnativeTestCrediantials.setStoredApptoken(APP_TOKEN)
        
        // Create requests corresponding to each placementId and add in cellRequests Array
        for placementID in placements {
            cellRequests.append(CellRequestModel.init(appToken: APP_TOKEN, placementID: placementID))
        }
        
        // Load the table view
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
    
    /**
    Load table view cells corresponding to Placements Id fetched from NSUserDefaults
    */
    func displayPlacementsList() {
        
        let appToken : String? = PubnativeTestCrediantials.storedApptoken()
        var placements : [String]? = PubnativeTestCrediantials.storedPlacements()
        
        // Check if App token and placements available
        if (appToken != nil && appToken?.characters.count > 0 &&
            placements != nil && placements?.count > 0) {
                
                // Make an array of requests
                var newRequests : [CellRequestModel] = []
                
                // Get the old requests (if any)
                for request in cellRequests {
                    
                    // If there is some old request corresponding to placementId
                    var isOldRequest    : Bool  = false
                    
                    // Get the index to remove from old requests
                    var removeAtIndex   : Int   = 0
                    
                    for index in 0..<placements!.count {
                        
                        let placement = placements![index]
                        
                        if placement == request.placementID {
                            
                            // If there is some old request corresponding to placementId then that is old request
                            isOldRequest = true
                            
                            // Get the index for the request that need to be removed from old requests
                            removeAtIndex = index
                            
                            break
                        }
                    }
                    
                    // If old request so can reuse it
                    if (isOldRequest) {
                        
                        // Add in new requests
                        newRequests.append(request)
                        
                        // Remove from old requests
                        placements?.removeAtIndex(removeAtIndex)
                    }
                }
                
                // Add the remaining requests corresponding to placementsId left
                for placementID : String in placements! {
                    newRequests.append(CellRequestModel.init(appToken: APP_TOKEN, placementID: placementID))
                }
                
                // Update the cellRequest with new requests
                cellRequests = newRequests
                
                // Reload the table view with new requests
                tableViewAds.reloadData()
        }
    }
    
    // MARK: Table View Data Source Methods
    
    /**
    Tells the data source to return the number of rows in a given section of a table view.
    The table-view object requesting this information

    @param tableView The table-view object requesting this information.
    @param section An index number identifying a section in tableView.
    
    @return The number of rows in section.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellRequests.count
    }
    
    /**
     Asks the data source for a cell to insert in a particular location of the table view.
     A table-view object requesting the cell
     
     @param tableView The table-view object requesting the cell.
     @param indexPath An index path locating a row in tableView.
     
     @return An object inheriting from UITableViewCell that the table view can use for the specified row
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get the reusable cell
        let cell: NativeAdTableViewCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdTableViewCell
        
        // Set the model for cell
        if indexPath.row < cellRequests.count {
            cell.setRequestModel(cellRequests[indexPath.row], indexPath:indexPath, viewController: self);
        }
        
        return cell
    }
}
