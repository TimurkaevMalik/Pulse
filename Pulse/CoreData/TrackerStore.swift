//
//  TrackerStore.swift
//  Pulse
//
//  Created by Malik Timurkaev on 06.05.2024.
//

import UIKit
import CoreData


protocol TrackerStoreProtocol {
   func storeNewTracker(_ tracker: Tracker, for categoryTitle: String)
   func updateTracker(_ tracker: Tracker, for categoryTitle: String)
   func fetchTracker(with id: UUID) -> Tracker?
   func updateCategoriesArray() -> [TrackerCategory]?
   func deleteTrackerOf(categoryTitle: String, id: UUID)
   func deleteTrackerWith(id: UUID)
}

final class TrackerStore: NSObject {
    
    private weak var delegate: TrackerStoreDelegate?
    private var appDelegate: AppDelegate
    internal let context: NSManagedObjectContext
    private var fectchedResultController: NSFetchedResultsController<TrackerCoreData>?
    internal let uiColorMarshalling = UIColorMarshalling()
    private let trackerCategoryStore: TrackerCategoryStore
    
    private let trackerName = "TrackerCoreData"
    
    
    init(_ delegate: TrackerStoreDelegate, appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.delegate = delegate
        self.context = appDelegate.persistentContainer.viewContext
        self.trackerCategoryStore = TrackerCategoryStore(appDelegate: appDelegate)
        super.init()
        
        let sortDescription = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: trackerName)
        fetchRequest.sortDescriptors = [sortDescription]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        self.fectchedResultController = controller
        try? controller.performFetch()
    }
    
    private func fetchAllTrackers() -> [TrackerCoreData]? {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: trackerName)
        
        do {
            let tracker = try context.fetch(fetchRequest)
            
            return tracker
        } catch let error as NSError{
            assertionFailure("\(error)")
            return nil
        }
    }
    
    private func deleteAllTrackers() {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: trackerName)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            trackers.forEach({ context.delete($0) })
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            assertionFailure("\(error)")
        }
    }
    
    private func convertCoreDataToTracker(_ trackerCoreData: TrackerCoreData) -> Tracker? {
        
        var tracker: Tracker
        let schedule = trackerCoreData.schedule != nil ? trackerCoreData.schedule : nil
        
        if let id = trackerCoreData.id,
           let name = trackerCoreData.name,
           let colorHexString = trackerCoreData.color,
           let emoji = trackerCoreData.emoji
        {
            tracker = Tracker(
                id: id,
                name: name,
                color: uiColorMarshalling.color(from: colorHexString),
                emoji: emoji,
                schedule: schedule?.components(separatedBy: " ") ?? [])
            
            return tracker
        }
        
        return nil
    }
    
    private func convertToArrayOfTrackers(_ response: [TrackerCoreData]) -> [Tracker] {
        
        var trackerArray: [Tracker] = []
        
        for trackerCoreData in response {
            
            let schedule = trackerCoreData.schedule != nil ? trackerCoreData.schedule : nil
            
            if let id = trackerCoreData.id,
               let name = trackerCoreData.name,
               let colorHexString = trackerCoreData.color,
               let emoji = trackerCoreData.emoji
            {
                let tracker = Tracker(
                    id: id,
                    name: name,
                    color: uiColorMarshalling.color(from: colorHexString),
                    emoji: emoji,
                    schedule: schedule?.components(separatedBy: " ") ?? [])
                
                trackerArray.append(tracker)
            }
        }
        
        return trackerArray
    }
}

extension TrackerStore: TrackerStoreProtocol {
    
    func storeNewTracker(_ tracker: Tracker, for categoryTitle: String) {
        
        guard let trackerEntityDescription = NSEntityDescription.entity(forEntityName: trackerName, in: context ) else { return }
        
        let trackerCoreData = TrackerCoreData(entity: trackerEntityDescription, insertInto: context)
        
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        
        if !tracker.schedule.isEmpty {
            let schedule: [String] = tracker.schedule.map { element in
                
                return element ?? ""
            }
            let weekdays: String = schedule.joined(separator: " ")
            
            trackerCoreData.schedule = weekdays
            
        } else {
            trackerCoreData.schedule = nil
        }
        
        let categoryCoreData = trackerCategoryStore.fetchCategory(with: categoryTitle)
        
        categoryCoreData?.titleOfCategory = categoryTitle
        categoryCoreData?.addToTrackersArray(trackerCoreData)
        
        appDelegate.saveContext()
    }
    
    func updateTracker(_ tracker: Tracker, for categoryTitle: String) {
        guard let trackersCoreData = fetchAllTrackers() else { return }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        let filteredCoreData = trackersCoreData.filter({ $0.id == tracker.id })
        
        filteredCoreData.forEach { filteredTracker in
            
            filteredTracker.name = tracker.name
            filteredTracker.color = uiColorMarshalling.hexString(from: tracker.color)
            filteredTracker.emoji = tracker.emoji
            
            if !tracker.schedule.isEmpty {
                let schedule: [String] = tracker.schedule.map { element in
                    
                    return element ?? ""
                }
                let weekdays: String = schedule.joined(separator: " ")
                
                filteredTracker.schedule = weekdays
                
            } else {
                filteredTracker.schedule = nil
            }
        }
        
        
        if let nonpinedTracker = filteredCoreData.first(where: { $0.trackerCategory?.titleOfCategory != pinedText }),
           let oldTitle = nonpinedTracker.trackerCategory?.titleOfCategory,
           oldTitle != categoryTitle {
            
            let oldCategory = trackerCategoryStore.fetchCategory(with: oldTitle)
            oldCategory?.removeFromTrackersArray(nonpinedTracker)
            
           let newCategory = trackerCategoryStore.fetchCategory(with: categoryTitle)
            newCategory?.addToTrackersArray( nonpinedTracker )
        }
        
        appDelegate.saveContext()
    }
    
    func fetchTracker(with id: UUID) -> Tracker? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: trackerName)
        
        do {
            guard let trackerCoreData = try context.fetch(fetchRequest).first(where: { $0.id == id }) else {
                return nil
            }
            
           return convertCoreDataToTracker(trackerCoreData)
            
        } catch let error as NSError {
            assertionFailure("\(error)")
            return nil
        }
    }
    
    func deleteTrackerOf(categoryTitle: String, id: UUID) {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: trackerName)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            
            guard let tracker = (trackers.filter( { $0.id == id }).first { $0.trackerCategory?.titleOfCategory == categoryTitle }) else { return }
            
            context.delete(tracker)
            appDelegate.saveContext()
            
        } catch let error as NSError {
            assertionFailure("\(error)")
        }
    }
    
    func deleteTrackerWith(id: UUID) {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: trackerName)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            
            let tracker = trackers.filter( { $0.id == id })
            
            tracker.forEach({ context.delete($0) })
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            assertionFailure("\(error)")
        }
    }
    
    func updateCategoriesArray() -> [TrackerCategory]? {
        
        guard let trackersCoreData = fetchAllTrackers() else {
            return nil
        }
        
        var categories: [TrackerCategory] = []
        
        for tracker in trackersCoreData {
            
            if let convertedTracker = convertCoreDataToTracker(tracker) {
                
                if !categories.isEmpty, categories.contains(where: { element in
                    element.titleOfCategory == tracker.trackerCategory?.titleOfCategory
                }) {
                    
                    for index in 0..<categories.count {
                        
                        if categories[index].titleOfCategory == tracker.trackerCategory?.titleOfCategory {
                            
                            var trackers: [Tracker] = categories[index].trackersArray
                            trackers.append(convertedTracker)
                            
                            categories[index] = TrackerCategory(titleOfCategory: categories[index].titleOfCategory, trackersArray: trackers)
                        }
                    }
                } else {
                    
                    categories.append(TrackerCategory(titleOfCategory: tracker.trackerCategory?.titleOfCategory ?? "", trackersArray: [convertedTracker]))
                }
            }
        }
        
        return categories.sorted(by: { $0.titleOfCategory < $1.titleOfCategory })
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard
            let trackerCoreData = anObject as? TrackerCoreData,
            let tracker = convertCoreDataToTracker(trackerCoreData)
        else { return }
        
        switch type {
            
        case .insert:
            if let title = trackerCoreData.trackerCategory?.titleOfCategory {
                delegate?.didAdd(tracker: tracker, with: title)
            }
            
        case .delete:
            delegate?.didDelete(tracker: tracker)
            
        case .update:
            if let title = trackerCoreData.trackerCategory?.titleOfCategory {
                delegate?.didUpdate(tracker: tracker, categoryTitle: title)
            }
        default:
            break
        }
    }
}
