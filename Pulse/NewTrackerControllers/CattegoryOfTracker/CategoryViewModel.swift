//
//  CategoryViewModel.swift
//  Pulse
//
//  Created by Malik Timurkaev on 19.05.2024.
//

import Foundation

final class CategoryViewModel {
    
    weak var newCategoryDelegate: NewCategoryViewProtocol?
    private weak var categoryModelDelegate: CategoryModelDelegate?
    private let trackerCategoryStore: TrackerCategoryStore
    
    private(set) var newCategory: String?
    private(set) var chosenCategory: String? {
        didSet {
            chosenCategoryBinding?(chosenCategory)
        }
    }
    
    private(set) var categories: [String] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    var chosenCategoryBinding:  Binding<String?>?
    var categoriesBinding: Binding<[String]>?
    
    
    init(categoryStore: TrackerCategoryStore,
         chosenCategory: String?,
         categoryModelDelegate: CategoryModelDelegate) {
        
        self.trackerCategoryStore = categoryStore
        self.chosenCategory = chosenCategory
        self.categoryModelDelegate = categoryModelDelegate
        trackerCategoryStore.delegate = self
        categories = fetchCategories()
    }
    
    func updateNameOfNewCategory(_ name: String?) {
        newCategory = name
    }
    
    func updateChosenCategory(_ name: String) {
        
        if chosenCategory == name {
            chosenCategory = nil
        } else {
            chosenCategory = name
        }
    }
    
    func categoryViewWillDissapear() {
        categoryModelDelegate?.didDismissScreenWithChangesIn(chosenCategory)
    }
    
    func didChoseCategory(_ category: String) {
        categoryModelDelegate?.didChooseCategory(category)
    }
    
    func storeNewCategory(_ category: TrackerCategory) {
        trackerCategoryStore.storeCategory(category)
    }
    
    private func fetchCategories() -> [String] {
        
        guard let categoryCoreData = trackerCategoryStore.fetchAllCategories() else {
            return []
        }
        let convertedCategories = convertToCategotyArray(categoryCoreData)
        
        
        return convertedCategories.map({ $0.titleOfCategory })
    }
    
    private func convertToCategotyArray( _ response: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        
        var categoryArray: [TrackerCategory] = []
        for categoryCoreData in response {
            
            if let title = categoryCoreData.titleOfCategory {
                let category = TrackerCategory(titleOfCategory: title, trackersArray: [])
                categoryArray.append(category)
            }
        }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        
        return categoryArray.filter({$0.titleOfCategory != pinedText})
    }
}

extension CategoryViewModel: CategoryStoreDelegate {
    func didStoreCategory(_ category: TrackerCategory) {
        categories.append(category.titleOfCategory)
        newCategoryDelegate?.didStoreNewCategory()
    }
    
    func storeDidUpdate(category: TrackerCategory) {
        newCategoryDelegate?.categoryAlreadyExists()
    }
}
