//
//  PubnativeTestCrediantials.swift
//  mediation
//
//  Created by Mohit on 19/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

import UIKit

class PubnativeTestCrediantials: NSObject {

    static let USER_DEFAULTS_KEY_PLACEMENTS    : String = "placements_key"
    static let USER_DEFAULTS_KEY_APP_TOKEN     : String = "app_token_key"
    
    class func storedPlacements() -> Array<String>? {
        let placements : Array<String>? = NSUserDefaults.standardUserDefaults().objectForKey(USER_DEFAULTS_KEY_PLACEMENTS) as? Array<String>
        return placements;
    }
    
    class func setStoredPlacements(placements: Array<String>?) {
        if (placements == nil || placements?.count == 0) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(USER_DEFAULTS_KEY_PLACEMENTS)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(placements, forKey: USER_DEFAULTS_KEY_PLACEMENTS)
        }
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    class func storedApptoken() -> String? {
        let appToken : String? = NSUserDefaults.standardUserDefaults().objectForKey(USER_DEFAULTS_KEY_APP_TOKEN) as? String
        return appToken;
    }
    
    class func setStoredApptoken(appToken: String?) {
        if (appToken != nil && appToken?.characters.count > 0) {
            NSUserDefaults.standardUserDefaults().setObject(appToken!, forKey: USER_DEFAULTS_KEY_APP_TOKEN)
            NSUserDefaults.standardUserDefaults().synchronize();
        }
    }
}
