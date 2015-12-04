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
        // Set the title at the navigation bar on top
        navigationItem.title = "SettingViewController"
        
        // Registers a class for use in creating new table cells.
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
    
    /**
    Load and display the app token and placementIds stored in NSUserDefaults
    */
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
        
        // Load the placement Ids in the table view
        tableViewPlacements.reloadData()
    }
    
    /**
     Update the NSUserDefaults with app token and placements shown on screen
     */
    func saveCredentials() {
        
        // Update NSUserDefaults app token if app token textfield is not empty
        if (textFieldAppToken.text?.characters.count > 0 &&
            textFieldPlacementId.text?.characters.count > 0) {
                PubnativeTestCrediantials.setStoredApptoken(textFieldAppToken.text)
        }
        
        // Update NSUserDefaults placements with the list shown in tableView
        PubnativeTestCrediantials.setStoredPlacements(placements)
        
        // Reset the stored config when credentials are saved.
        onResetConfigClicked(nil)
    }
    
    // MARK: Button Actions
    
    /**
    Reset the stored config
    */
    @IBAction func onResetConfigClicked(sender: AnyObject?) {
        
        if (PubnativeConfigManager.clean()){
            KSToastView.ks_showToast("Stored config reset!");
        } else {
            KSToastView.ks_showToast("Error!");
        }
    }
    
    /**
     Add the placement Id text in the tableView list
     */
    @IBAction func onAddPlacementClicked(sender: AnyObject) {
        
        let placementId : String? = textFieldPlacementId.text
        
        // Add if text is not empty
        if (placementId?.characters.count > 0) {
            
            // Add the placement Id in data source of table view
            placements.append(placementId!)
            
            // Empty the text entered in the textField
            textFieldPlacementId.text = ""
            
            // Reload the tableView with added placement Id as well
            tableViewPlacements.reloadData()
            
            KSToastView.ks_showToast("Placement Id added!");
            
        } else {
            KSToastView.ks_showToast("Error : Empty Placement Id!");
        }
    }
    
    /**
     Back button pressed
     */
    func onBackPressed() {
        saveCredentials()
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
        return placements.count
    }
    
    /**
     Asks the data source for a cell to insert in a particular location of the table view.
     A table-view object requesting the cell
     
     @param tableView The table-view object requesting the cell.
     @param indexPath An index number identifying a section in tableView.
     
     @return An object inheriting from UITableViewCell that the table view can use for the specified row
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get the reusable cell
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)!
        
        if indexPath.row < placements.count {
            cell.textLabel?.text = placements[indexPath.row]
        }
        
        return cell
    }
    
    /**
     Asks the data source to verify that the given row is editable.
     The table-view object requesting this information.
     
     @param tableView The table-view object requesting this information.
     @param indexPath An index path locating a row in tableView.
     
     @return An object inheriting from UITableViewCell that the table view can use for the specified row
     */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // Returning true to show delete button on swipping to left in tableview
        return true;
    }
    
    /**
     Asks the data source to commit the insertion or deletion of a specified row in the receiver.
     The table-view object requesting the insertion or deletion.
     
     @param tableView The table-view object requesting this information.
     @param editingStyle The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Can be delete or insert
     @param indexPath An index path locating the row in tableView.
     
     @return An object inheriting from UITableViewCell that the table view can use for the specified row
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // If editing sytle is Delete
        if (editingStyle == UITableViewCellEditingStyle.Delete &&
            indexPath.row < placements.count) {
                
                // Update the table view data source
                placements.removeAtIndex(indexPath.row)
                
                // Reload table view after deleting the placement from the list
                tableView.reloadData()
        }
    }
}

