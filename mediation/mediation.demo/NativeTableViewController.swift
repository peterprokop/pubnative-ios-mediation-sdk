//
//  NativeTableViewController.swift
//  mediation
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation

class NativeTableViewController: UITableViewController {
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UITableViewController -
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var result = 0
        if(Settings.placements.count>0) {
            result = 1
        }
        return result
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.placements.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "NativeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NativeTableViewCell
        cell.controller = self
        cell.placementName = Settings.placements[indexPath.row]
        return cell
    }
    
    // MARK: - NativeTableViewController -
    
}