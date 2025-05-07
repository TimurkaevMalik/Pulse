//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Malik Timurkaev on 06.05.2024.
//

import UIKit
import CoreData


final class TrackerCategoryStore: NSObject {
    
    weak var delegate: CategoryStoreDelegate?
    private let appDelegate: AppDelegate
    private let context: NSManagedObjectContext
    private var fectchedResultController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    private let categoryName = "TrackerCategoryCoreData"
    
    init(appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        
        let sortDescriptions = NSSortDescriptor(keyPath: \TrackerCategoryCoreData.titleOfCategory, ascending: true)
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: categoryName)
        fetchRequest.sortDescriptors = [sortDescriptions]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        fectchedResultController = controller
        try? fectchedResultController?.performFetch()
    }
    
    
    func storeCategory(_ category: TrackerCategory) {
        
        guard fetchCategory(with: category.titleOfCategory) == nil else {
            updateCategory(category)
            return
        }
        
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: categoryName, in: context ) else {
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(entity: categoryEntityDescription, insertInto: context)
        
        categoryCoreData.titleOfCategory = category.titleOfCategory
        
        appDelegate.saveContext()
    }
    
    func updateCategory(_ category: TrackerCategory) {
        
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
    
    func fetchAllCategories() -> [TrackerCategoryCoreData]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: categoryName)
        let sortDescriptors = NSSortDescriptor(keyPath: \TrackerCategoryCoreData.titleOfCategory, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptors]
        
        do {
            let response = try context.fetch(fetchRequest) as? [TrackerCategoryCoreData]
            return response
            
        } catch let error as NSError {
            assertionFailure("\(error)")
            return nil
        }
    }
    
    func fetchCategory(with title: String) -> TrackerCategoryCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: categoryName)
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            return categories.first(where: { category in
                category.titleOfCategory == title })
            
        } catch let error as NSError {
            assertionFailure("\(error)")
            return nil
        }
    }
    
    func deleteTrackerWith(_ id: UUID, from categoryTitle: String) {
        
        guard
            let categoryCoreData = fetchCategory(with: categoryTitle),
            let tracker = categoryCoreData.trackersArray?.first(where: { ($0 as? TrackerCoreData)?.id == id }) as? NSManagedObject
        else {
            return
        }
    
        context.delete(tracker)
        
        appDelegate.saveContext()
    }
    
    func convertToCategotyArray( _ response: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        
        var categoryArray: [TrackerCategory] = []
        for categoryCoreData in response {
            
            if let title = categoryCoreData.titleOfCategory {
                let category = TrackerCategory(titleOfCategory: title, trackersArray: [])
                categoryArray.append(category)
            }
        }
        
        return categoryArray
    }
    
    private func convertCoreDataToCategory( _ categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        
        var category: TrackerCategory
        
        if let title = categoryCoreData.titleOfCategory {
            
            category = TrackerCategory(titleOfCategory: title, trackersArray: [])
            
            return category
        }
        
        return nil
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard
            let categoryCoreData = anObject as? TrackerCategoryCoreData,
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
