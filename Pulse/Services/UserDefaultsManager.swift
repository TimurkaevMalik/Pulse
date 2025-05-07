//
//  UserDefaultsManager.swift
//  Pulse
//
//  Created by Malik Timurkaev on 21.05.2024.
//

import UIKit

class UserDefaultsManager {
    
    
    private static let wasOnboardinShownKey = "wasOnboardinShown"
    private static let chosenFilterKey = "chosenFilter"
    
    static var chosenFilter: String? {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsManager.chosenFilterKey)
        } set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsManager.chosenFilterKey)
        }
    }
    
    static var wasOnboardinShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultsManager.wasOnboardinShownKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsManager.wasOnboardinShownKey)
            
            if newValue == true {
                
                chosenFilter = "allTrackers"
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                let trackerCategoryStore = TrackerCategoryStore(appDelegate: appDelegate)
                
                trackerCategoryStore.storeCategory(TrackerCategory(titleOfCategory: "Pined", trackersArray: []))
            }
        }
    }
}
