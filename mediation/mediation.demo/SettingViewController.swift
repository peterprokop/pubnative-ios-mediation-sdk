//
//  ViewController.swift
//  mediation.demo
//
//  Created by David Martin on 07/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDataSource {
    
    let tableViewCellIdentifier = "PlacementTableViewCell"
    var placements : [String]   = []
    
    @IBOutlet weak var tableViewPlacements  : UITableView!
    @IBOutlet weak var textFieldAppToken    : UITextField!
    @IBOutlet weak var textFieldPlacementId : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SettingViewController"
        tableViewPlacements.registerClass(UITableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        displayStoredValues()
    }
    
    override func viewWillDisappear(animated: Bool) {
        onBackPressed()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Values
    func displayStoredValues() {
        let appToken : String? = PubnativeTestCrediantials.storedApptoken()
        if (appToken != nil && appToken?.characters.count > 0) {
            textFieldAppToken.text = appToken!
        }
        let storedPlacements = PubnativeTestCrediantials.storedPlacements()
        if (storedPlacements == nil) {
            placements = []
        } else {
            placements = storedPlacements!
        }
        tableViewPlacements.reloadData()
    }
    
    func saveCredentials() {
        if (textFieldAppToken.text?.characters.count > 0 &&
            textFieldPlacementId.text?.characters.count > 0) {
                PubnativeTestCrediantials.setStoredApptoken(textFieldAppToken.text)
        }
        PubnativeTestCrediantials.setStoredPlacements(placements)
        
        // reset the stored config when credentials are saved.
        onResetConfigClicked(nil)
    }
    
    // MARK: Button Actions
    @IBAction func onResetConfigClicked(sender: AnyObject?) {
        if (PubnativeConfigManager.clean()){
            KSToastView.ks_showToast("Stored config reset!");
        } else {
            KSToastView.ks_showToast("Error!");
        }
    }
    
    @IBAction func onAddPlacementClicked(sender: AnyObject) {
        let placementId : String? = textFieldPlacementId.text
        if (placementId?.characters.count > 0) {
            placements.append(placementId!)
            textFieldPlacementId.text = ""
            tableViewPlacements.reloadData()
            KSToastView.ks_showToast("Placement Id added!");
        } else {
            KSToastView.ks_showToast("Error : Empty Placement Id!");
        }
    }
    
    func onBackPressed() {
        saveCredentials()
    }
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)!
        if indexPath.row < placements.count {
            cell.textLabel?.text = placements[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if (indexPath.row < placements.count) {
                placements.removeAtIndex(indexPath.row)
                tableView.reloadData()
            }
        }
    }
}

