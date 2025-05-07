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
                
                chosenFilter = "allTasks"
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                let taskCategoryStore = TaskCategoryStore(appDelegate: appDelegate)
                
                taskCategoryStore.storeCategory(TaskCategory(titleOfCategory: "Pined", tasksArray: []))
            }
        }
    }
}
