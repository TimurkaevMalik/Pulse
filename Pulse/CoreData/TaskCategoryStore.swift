//
//  TaskCategoryStore.swift
//  Pulse
//
//  Created by Malik Timurkaev on 06.05.2024.
//

import UIKit
import CoreData


final class TaskCategoryStore: NSObject {
    
    weak var delegate: CategoryStoreDelegate?
    private let appDelegate: AppDelegate
    private let context: NSManagedObjectContext
    private var fectchedResultController: NSFetchedResultsController<TaskCategoryCoreData>?
    
    private let categoryName = "TaskCategoryCoreData"
    
    init(appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        
        let sortDescriptions = NSSortDescriptor(keyPath: \TaskCategoryCoreData.titleOfCategory, ascending: true)
        let fetchRequest = NSFetchRequest<TaskCategoryCoreData>(entityName: categoryName)
        fetchRequest.sortDescriptors = [sortDescriptions]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        fectchedResultController = controller
        try? fectchedResultController?.performFetch()
    }
    
    
    func storeCategory(_ category: TaskCategory) {
        
        guard fetchCategory(with: category.titleOfCategory) == nil else {
            updateCategory(category)
            return
        }
        
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: categoryName, in: context ) else {
            return
        }
        
        let categoryCoreData = TaskCategoryCoreData(entity: categoryEntityDescription, insertInto: context)
        
        categoryCoreData.titleOfCategory = category.titleOfCategory
        
        appDelegate.saveContext()
    }
    
    func updateCategory(_ category: TaskCategory) {
        
        guard let categoryCoreData = fetchCategory(with: category.titleOfCategory) else {
            return
        }
        categoryCoreData.titleOfCategory = category.titleOfCategory
        
        appDelegate.saveContext()
    }
    
    func locolizePinedCategory() {
        
        if Locale.current.languageCode == "ru" {
            if fetchCategory(with: "Закрепленные") == nil {
                
                guard let categoryCoreData = fetchCategory(with: "Pined") else {
                    return
                }
                
                categoryCoreData.titleOfCategory = "Закрепленные"
                appDelegate.saveContext()
                
            }
        } else if Locale.current.languageCode == "en" {
                
            if fetchCategory(with: "Pined") == nil {
                
                guard let categoryCoreData = fetchCategory(with: "Закрепленные") else {
                    return
                }
                
                categoryCoreData.titleOfCategory = "Pined"
                appDelegate.saveContext()
            }
        }
    }
    
    func fetchAllCategories() -> [TaskCategoryCoreData]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: categoryName)
        let sortDescriptors = NSSortDescriptor(keyPath: \TaskCategoryCoreData.titleOfCategory, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptors]
        
        do {
            let response = try context.fetch(fetchRequest) as? [TaskCategoryCoreData]
            return response
            
        } catch let error as NSError {
            assertionFailure("\(error)")
            return nil
        }
    }
    
    func fetchCategory(with title: String) -> TaskCategoryCoreData? {
        let fetchRequest = NSFetchRequest<TaskCategoryCoreData>(entityName: categoryName)
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            return categories.first(where: { category in
                category.titleOfCategory == title })
            
        } catch let error as NSError {
            assertionFailure("\(error)")
            return nil
        }
    }
    
    func deleteTaskWith(_ id: UUID, from categoryTitle: String) {
        
        guard
            let categoryCoreData = fetchCategory(with: categoryTitle),
            let task = categoryCoreData.tasksArray?.first(where: { ($0 as? TaskCoreData)?.id == id }) as? NSManagedObject
        else {
            return
        }
    
        context.delete(task)
        
        appDelegate.saveContext()
    }
    
    func convertToCategotyArray( _ response: [TaskCategoryCoreData]) -> [TaskCategory] {
        
        var categoryArray: [TaskCategory] = []
        for categoryCoreData in response {
            
            if let title = categoryCoreData.titleOfCategory {
                let category = TaskCategory(titleOfCategory: title, tasksArray: [])
                categoryArray.append(category)
            }
        }
        
        return categoryArray
    }
    
    private func convertCoreDataToCategory( _ categoryCoreData: TaskCategoryCoreData) -> TaskCategory? {
        
        var category: TaskCategory
        
        if let title = categoryCoreData.titleOfCategory {
            
            category = TaskCategory(titleOfCategory: title, tasksArray: [])
            
            return category
        }
        
        return nil
    }
}

extension TaskCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard
            let categoryCoreData = anObject as? TaskCategoryCoreData,
            let category = convertCoreDataToCategory(categoryCoreData)
        else { return }
        
        switch type {
        case .insert:
            delegate?.didStoreCategory(category)
        case .update:
            delegate?.storeDidUpdate(category: category)
        case .delete:
            break
        default:
            break
        }
    }
}
