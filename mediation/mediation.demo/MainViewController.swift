//
//  MainViewController.swift
//  mediation
//
//  Created by Mohit on 20/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource {
    let APP_TOKEN                       = "e1a8e9fcf8aaeff31d1ddaee1f60810957f4c297859216dea9fa283043f8680f"
    var requests : [CellRequestModel]   = []
    
    @IBOutlet weak var tableViewAds: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayPlacementsList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initView() {
        navigationItem.title = "MainViewController"

        // Store test crediantials
        let placements = ["facebook_only"]
        PubnativeTestCrediantials.setStoredPlacements(placements)
        PubnativeTestCrediantials.setStoredApptoken(APP_TOKEN)
        for placementID in placements {
            requests.append(CellRequestModel.init(appToken: APP_TOKEN, placementID: placementID))
        }
        tableViewAds.reloadData()
    }
    
    func displayPlacementsList() {
        let appToken : String? = PubnativeTestCrediantials.storedApptoken()
        var placements : [String]? = PubnativeTestCrediantials.storedPlacements()
        if (appToken != nil && appToken?.characters.count > 0 &&
            placements != nil && placements?.count > 0) {
                var newRequests : [CellRequestModel] = []
                for request in requests {
                    //TODO: Implementation Pending 
                    //Check for equals overriding
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
                requests = newRequests
                tableViewAds.reloadData()
        }
    }
    
    // MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AdCellTableViewCell = tableView.dequeueReusableCellWithIdentifier("AdCellTableViewCell") as! AdCellTableViewCell
        return cell
    }
}
