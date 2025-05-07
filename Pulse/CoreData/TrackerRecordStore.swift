//
//  TrackerRecordStore.swift
//  Pulse
//
//  Created by Malik Timurkaev on 06.05.2024.
//

import UIKit
import CoreData

protocol RecordStoreProtocol {
    var context: NSManagedObjectContext { get }
    
    func storeRecord(_ record: TrackerRecord)
    func updateRecord(_ record: TrackerRecord)
    func deleteRecord(_ record: TrackerRecord)
    func deleteAllRecordsOfTracker(_ id: UUID)
    func fetchAllConvertedRecords() -> [TrackerRecord]
    func fetchConvertedRecordWith(id: UUID) -> TrackerRecord?
}

final class TrackerRecordStore: NSObject {
    
    private weak var delegate: RecordStoreDelegate?
    private let appDelegate: AppDelegate
    internal let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    private var dateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.calendar = .current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        
        return formatter
    }
    
    private let recordName = "TrackerRecordCoreData"
    private let dateName = "DateCoreData"
    
    
    init(_ delegate: RecordStoreDelegate, appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.delegate = delegate
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        
        let sortDescription = NSSortDescriptor(keyPath: \TrackerRecordCoreData.id, ascending: false)
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: recordName)
        fetchRequest.sortDescriptors = [sortDescription]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        fetchedResultController = controller
        try? controller.performFetch()
    }
    
    
    private func fetchAllRecords() -> [TrackerRecordCoreData] {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: recordName)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records
            
        } catch let error as NSError {
            
            assertionFailure("\(error)")
            return []
        }
    }
    
    private func fetchRecordWith(id: UUID) -> TrackerRecordCoreData? {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: recordName)
        
        do {
            let recordCoreData = try context.fetch(fetchRequest).first(where: { $0.id == id })
            return recordCoreData
            
        } catch let error as NSError {
            
            assertionFailure("\(error)")
            return nil
        }
    }
    
    private func getDateArrayFromStrings(of record: TrackerRecordCoreData) -> [Date] {
        
        var dates: [Date] = []
        if  let datesString = record.datesString?.components(separatedBy: ",") {
            
            for dateString in datesString {
                
                if let date = dateFormatter.date(from: dateString) {
                    dates.append(date)
                }
            }
            
        }
        return dates
    }
}

extension TrackerRecordStore: RecordStoreProtocol {
    
    func storeRecord(_ record: TrackerRecord){
        
        guard let recordEntityDescription = NSEntityDescription.entity(forEntityName: recordName, in: context) else { return }
        
        let recordCoreData = TrackerRecordCoreData(entity: recordEntityDescription, insertInto: context)
        
        recordCoreData.id = record.id
        
        let dates = record.date.map({ "\($0)"})
        recordCoreData.datesString = dates.joined(separator: ",")
        
        appDelegate.saveContext()
    }
    
    func fetchAllConvertedRecords() -> [TrackerRecord] {
        
        let records = fetchAllRecords()
        
        var convertedRecords: [TrackerRecord] = []
        
        for record in records {
            
            if let id = record.id {
                
                let dates: [Date] = getDateArrayFromStrings(of: record)
                convertedRecords.append(TrackerRecord(id: id, date: dates))
            }
        }
        
        return convertedRecords
    }
    
    func fetchConvertedRecordWith(id: UUID) -> TrackerRecord? {
        
        guard
            let recordCoreData = fetchRecordWith(id: id),
            let  datesStringArray = recordCoreData.datesString?.components(separatedBy: ",")
        else { return nil }
        
        let datesFormated = datesStringArray.map({ dateFormatter.date(from: $0) })
        
        var dates = [Date]()
        
        for date in datesFormated {
            if let date {
                dates.append(date)
            } else {
                return nil
            }
        }
        
        let record = TrackerRecord(id: id, date: dates)
        
        return record
    }
    
    func updateRecord(_ record: TrackerRecord) {
        
        guard let recordCoreData = fetchRecordWith(id: record.id) else { return }
        
        recordCoreData.id = record.id
        
        let dates = record.date.map({ "\($0)"})
        recordCoreData.datesString = dates.joined(separator: ",")
        
        appDelegate.saveContext()
    }
    
    func deleteAllRecordsWith(id: UUID) {
        guard let recordCoreData = fetchRecordWith(id: id) else { return }
        
        context.delete(recordCoreData)
        appDelegate.saveContext()
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        
        guard let recordCoreData = fetchRecordWith(id: record.id) else { return }
        
        let datesString = record.date.map({ "\($0)"})
        
        if record.date.count != 0 {
            recordCoreData.datesString = datesString.joined(separator: ",")
        } else {
            context.delete(recordCoreData)
        }
        
        appDelegate.saveContext()
    }
    
    func deleteAllRecordsOfTracker(_ id: UUID) {
        guard let recordCoreData = fetchRecordWith(id: id) else { return }
        
        context.delete(recordCoreData)
        appDelegate.saveContext()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard
            let recordCoreData = anObject as? TrackerRecordCoreData,
            let id = recordCoreData.id
        else { return }
        
        let dates = getDateArrayFromStrings(of: recordCoreData)
        let record = TrackerRecord(id: id, date: dates)
        
        switch type {
            
        case .insert:
            delegate?.didAdd(record: record)
        case .delete:
            delegate?.didDelete(record: record)
        case .update:
            delegate?.didUpdate(record: record)
        default:
            break
        }
    }
}
