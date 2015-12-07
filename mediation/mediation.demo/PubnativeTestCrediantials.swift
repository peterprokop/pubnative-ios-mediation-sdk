//
//  PubnativeTestCrediantials.swift
//  mediation
//
//  Created by Mohit on 19/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class PubnativeTestCrediantials: NSObject {
    
    static let kUserDefaultsStoredPlacementsKey : String = "net.pubnative.mediation.demo.PubnativeTestCrediantials.placementsKey"
    static let kUserDefaultsStoredAppTokenKey   : String = "net.pubnative.mediation.demo.PubnativeTestCrediantials.app_token_key"
    
    class func storedPlacements() -> Array<String>? {
        let placements : Array<String>? = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultsStoredPlacementsKey) as? Array<String>
        return placements;
    }
    
    class func setStoredPlacements(placements: Array<String>?) {
        if (placements == nil || placements?.count == 0) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserDefaultsStoredPlacementsKey)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(placements, forKey: kUserDefaultsStoredPlacementsKey)
        }
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    class func storedApptoken() -> String? {
        let appToken : String? = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultsStoredAppTokenKey) as? String
        return appToken;
    }
    
    class func setStoredApptoken(appToken: String?) {
        if (appToken != nil && appToken?.characters.count > 0) {
            NSUserDefaults.standardUserDefaults().setObject(appToken!, forKey: kUserDefaultsStoredAppTokenKey)
            NSUserDefaults.standardUserDefaults().synchronize();
        }
    }
}
