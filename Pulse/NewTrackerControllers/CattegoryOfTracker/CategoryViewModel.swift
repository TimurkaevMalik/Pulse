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
    private let taskCategoryStore: TaskCategoryStore
    
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
    
    
    init(categoryStore: TaskCategoryStore,
         chosenCategory: String?,
         categoryModelDelegate: CategoryModelDelegate) {
        
        self.taskCategoryStore = categoryStore
        self.chosenCategory = chosenCategory
        self.categoryModelDelegate = categoryModelDelegate
        taskCategoryStore.delegate = self
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
    
    func storeNewCategory(_ category: TaskCategory) {
        taskCategoryStore.storeCategory(category)
    }
    
    private func fetchCategories() -> [String] {
        
        guard let categoryCoreData = taskCategoryStore.fetchAllCategories() else {
            return []
        }
        let convertedCategories = convertToCategotyArray(categoryCoreData)
        
        
        return convertedCategories.map({ $0.titleOfCategory })
    }
    
    private func convertToCategotyArray( _ response: [TaskCategoryCoreData]) -> [TaskCategory] {
        
        var categoryArray: [TaskCategory] = []
        for categoryCoreData in response {
            
            if let title = categoryCoreData.titleOfCategory {
                let category = TaskCategory(titleOfCategory: title, tasksArray: [])
                categoryArray.append(category)
            }
        }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        
        return categoryArray.filter({$0.titleOfCategory != pinedText})
    }
}

extension CategoryViewModel: CategoryStoreDelegate {
    func didStoreCategory(_ category: TaskCategory) {
        categories.append(category.titleOfCategory)
        newCategoryDelegate?.didStoreNewCategory()
    }
    
    func storeDidUpdate(category: TaskCategory) {
        newCategoryDelegate?.categoryAlreadyExists()
    }
}
