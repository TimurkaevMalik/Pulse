//
//  TaskRecordStore.swift
//  Pulse
//
//  Created by Malik Timurkaev on 06.05.2024.
//

import UIKit
import CoreData

protocol RecordStoreProtocol {
    var context: NSManagedObjectContext { get }
    
    func storeRecord(_ record: TaskRecord)
    func updateRecord(_ record: TaskRecord)
    func deleteRecord(_ record: TaskRecord)
    func deleteAllRecordsOfTask(_ id: UUID)
    func fetchAllConvertedRecords() -> [TaskRecord]
    func fetchConvertedRecordWith(id: UUID) -> TaskRecord?
}

final class TaskRecordStore: NSObject {
    
    private weak var delegate: RecordStoreDelegate?
    private let appDelegate: AppDelegate
    internal let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TaskRecordCoreData>?
    
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
    
    private let recordName = "TaskRecordCoreData"
    private let dateName = "DateCoreData"
    
    
    init(_ delegate: RecordStoreDelegate, appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.delegate = delegate
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        
        let sortDescription = NSSortDescriptor(keyPath: \TaskRecordCoreData.id, ascending: false)
        let fetchRequest = NSFetchRequest<TaskRecordCoreData>(entityName: recordName)
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
    
    
    private func fetchAllRecords() -> [TaskRecordCoreData] {
        let fetchRequest = NSFetchRequest<TaskRecordCoreData>(entityName: recordName)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records
            
        } catch let error as NSError {
            
            assertionFailure("\(error)")
            return []
        }
    }
    
    private func fetchRecordWith(id: UUID) -> TaskRecordCoreData? {
        let fetchRequest = NSFetchRequest<TaskRecordCoreData>(entityName: recordName)
        
        do {
            let recordCoreData = try context.fetch(fetchRequest).first(where: { $0.id == id })
            return recordCoreData
            
        } catch let error as NSError {
            
            assertionFailure("\(error)")
            return nil
        }
    }
    
    private func getDateArrayFromStrings(of record: TaskRecordCoreData) -> [Date] {
        
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

extension TaskRecordStore: RecordStoreProtocol {
    
    func storeRecord(_ record: TaskRecord){
        
        guard let recordEntityDescription = NSEntityDescription.entity(forEntityName: recordName, in: context) else { return }
        
        let recordCoreData = TaskRecordCoreData(entity: recordEntityDescription, insertInto: context)
        
        recordCoreData.id = record.id
        
        let dates = record.date.map({ "\($0)"})
        recordCoreData.datesString = dates.joined(separator: ",")
        
        appDelegate.saveContext()
    }
    
    func fetchAllConvertedRecords() -> [TaskRecord] {
        
        let records = fetchAllRecords()
        
        var convertedRecords: [TaskRecord] = []
        
        for record in records {
            
            if let id = record.id {
                
                let dates: [Date] = getDateArrayFromStrings(of: record)
                convertedRecords.append(TaskRecord(id: id, date: dates))
            }
        }
        
        return convertedRecords
    }
    
    func fetchConvertedRecordWith(id: UUID) -> TaskRecord? {
        
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
        
        let record = TaskRecord(id: id, date: dates)
        
        return record
    }
    
    func updateRecord(_ record: TaskRecord) {
        
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
    
    func deleteRecord(_ record: TaskRecord) {
        
        guard let recordCoreData = fetchRecordWith(id: record.id) else { return }
        
        let datesString = record.date.map({ "\($0)"})
        
        if record.date.count != 0 {
            recordCoreData.datesString = datesString.joined(separator: ",")
        } else {
            context.delete(recordCoreData)
        }
        
        appDelegate.saveContext()
    }
    
    func deleteAllRecordsOfTask(_ id: UUID) {
        guard let recordCoreData = fetchRecordWith(id: id) else { return }
        
        context.delete(recordCoreData)
        appDelegate.saveContext()
    }
}

extension TaskRecordStore: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard
            let recordCoreData = anObject as? TaskRecordCoreData,
            let id = recordCoreData.id
        else { return }
        
        let dates = getDateArrayFromStrings(of: recordCoreData)
        let record = TaskRecord(id: id, date: dates)
        
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
