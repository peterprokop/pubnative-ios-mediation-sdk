//
//  SettingsViewController.swift
//  mediation
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    @IBAction func reset(sender: AnyObject) {
     
        print("RESET PUSHED")
        PubnativeConfigManager.reset()
    }
}