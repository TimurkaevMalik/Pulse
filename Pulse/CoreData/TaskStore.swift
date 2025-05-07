//
//  TaskStore.swift
//  Pulse
//
//  Created by Malik Timurkaev on 06.05.2024.
//

import UIKit
import CoreData


protocol TaskStoreProtocol {
   func storeNewTask(_ task: TaskData, for categoryTitle: String)
   func updateTask(_ task: TaskData, for categoryTitle: String)
   func fetchTask(with id: UUID) -> TaskData?
   func updateCategoriesArray() -> [TaskCategory]?
   func deleteTaskOf(categoryTitle: String, id: UUID)
   func deleteTaskWith(id: UUID)
}

final class TaskStore: NSObject {
    
    private weak var delegate: TaskStoreDelegate?
    private var appDelegate: AppDelegate
    internal let context: NSManagedObjectContext
    private var fectchedResultController: NSFetchedResultsController<TaskCoreData>?
    internal let uiColorMarshalling = UIColorMarshalling()
    private let taskCategoryStore: TaskCategoryStore
    
    private let taskName = "TaskCoreData"
    
    
    init(_ delegate: TaskStoreDelegate, appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.delegate = delegate
        self.context = appDelegate.persistentContainer.viewContext
        self.taskCategoryStore = TaskCategoryStore(appDelegate: appDelegate)
        super.init()
        
        let sortDescription = NSSortDescriptor(keyPath: \TaskCoreData.name, ascending: true)
        let fetchRequest = NSFetchRequest<TaskCoreData>(entityName: taskName)
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
    
    private func fetchAllTasks() -> [TaskCoreData]? {
        
        let fetchRequest = NSFetchRequest<TaskCoreData>(entityName: taskName)
        
        do {
            let task = try context.fetch(fetchRequest)
            
            return task
        } catch let error as NSError{
            assertionFailure("\(error)")
            return nil
        }
    }
    
    private func deleteAllTasks() {
        let fetchRequest = NSFetchRequest<TaskCoreData>(entityName: taskName)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            tasks.forEach({ context.delete($0) })
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            assertionFailure("\(error)")
        }
    }
    
    private func convertCoreDataToTask(_ taskCoreData: TaskCoreData) -> TaskData? {
        
        var task: TaskData
        let schedule = taskCoreData.schedule != nil ? taskCoreData.schedule : nil
        
        if let id = taskCoreData.id,
           let name = taskCoreData.name,
           let colorHexString = taskCoreData.color,
           let emoji = taskCoreData.emoji
        {
            task = TaskData(
                id: id,
                name: name,
                color: uiColorMarshalling.color(from: colorHexString),
                emoji: emoji,
                schedule: schedule?.components(separatedBy: " ") ?? [])
            
            return task
        }
        
        return nil
    }
    
    private func convertToArrayOfTasks(_ response: [TaskCoreData]) -> [TaskData] {
        
        var taskArray: [TaskData] = []
        
        for taskCoreData in response {
            
            let schedule = taskCoreData.schedule != nil ? taskCoreData.schedule : nil
            
            if let id = taskCoreData.id,
               let name = taskCoreData.name,
               let colorHexString = taskCoreData.color,
               let emoji = taskCoreData.emoji
            {
                let task = TaskData(
                    id: id,
                    name: name,
                    color: uiColorMarshalling.color(from: colorHexString),
                    emoji: emoji,
                    schedule: schedule?.components(separatedBy: " ") ?? [])
                
                taskArray.append(task)
            }
        }
        
        return taskArray
    }
}

extension TaskStore: TaskStoreProtocol {
    
    func storeNewTask(_ task: TaskData, for categoryTitle: String) {
        
        guard let taskEntityDescription = NSEntityDescription.entity(forEntityName: taskName, in: context ) else { return }
        
        let taskCoreData = TaskCoreData(entity: taskEntityDescription, insertInto: context)
        
        taskCoreData.name = task.name
        taskCoreData.id = task.id
        taskCoreData.emoji = task.emoji
        
        taskCoreData.color = uiColorMarshalling.hexString(from: task.color)
        
        if !task.schedule.isEmpty {
            let schedule: [String] = task.schedule.map { element in
                
                return element ?? ""
            }
            let weekdays: String = schedule.joined(separator: " ")
            
            taskCoreData.schedule = weekdays
            
        } else {
            taskCoreData.schedule = nil
        }
        
        let categoryCoreData = taskCategoryStore.fetchCategory(with: categoryTitle)
        
        categoryCoreData?.titleOfCategory = categoryTitle
        categoryCoreData?.addToTasksArray(taskCoreData)
        
        appDelegate.saveContext()
    }
    
    func updateTask(_ task: TaskData, for categoryTitle: String) {
        guard let tasksCoreData = fetchAllTasks() else { return }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        let filteredCoreData = tasksCoreData.filter({ $0.id == task.id })
        
        filteredCoreData.forEach { filteredTask in
            
            filteredTask.name = task.name
            filteredTask.color = uiColorMarshalling.hexString(from: task.color)
            filteredTask.emoji = task.emoji
            
            if !task.schedule.isEmpty {
                let schedule: [String] = task.schedule.map { element in
                    
                    return element ?? ""
                }
                let weekdays: String = schedule.joined(separator: " ")
                
                filteredTask.schedule = weekdays
                
            } else {
                filteredTask.schedule = nil
            }
        }
        
        
        if let nonpinedTask = filteredCoreData.first(where: { $0.taskCategory?.titleOfCategory != pinedText }),
           let oldTitle = nonpinedTask.taskCategory?.titleOfCategory,
           oldTitle != categoryTitle {
            
            let oldCategory = taskCategoryStore.fetchCategory(with: oldTitle)
            oldCategory?.removeFromTasksArray(nonpinedTask)
            
           let newCategory = taskCategoryStore.fetchCategory(with: categoryTitle)
            newCategory?.addToTasksArray( nonpinedTask )
        }
        
        appDelegate.saveContext()
    }
    
    func fetchTask(with id: UUID) -> TaskData? {
        let fetchRequest = NSFetchRequest<TaskCoreData>(entityName: taskName)
        
        do {
            guard let taskCoreData = try context.fetch(fetchRequest).first(where: { $0.id == id }) else {
                return nil
            }
            
           return convertCoreDataToTask(taskCoreData)
            
        } catch let error as NSError {
            assertionFailure("\(error)")
            return nil
        }
    }
    
    func deleteTaskOf(categoryTitle: String, id: UUID) {
        
        let fetchRequest = NSFetchRequest<TaskCoreData>(entityName: taskName)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            guard let task = (tasks.filter( { $0.id == id }).first { $0.taskCategory?.titleOfCategory == categoryTitle }) else { return }
            
            context.delete(task)
            appDelegate.saveContext()
            
        } catch let error as NSError {
            assertionFailure("\(error)")
        }
    }
    
    func deleteTaskWith(id: UUID) {
        let fetchRequest = NSFetchRequest<TaskCoreData>(entityName: taskName)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            let task = tasks.filter( { $0.id == id })
            
            task.forEach({ context.delete($0) })
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            assertionFailure("\(error)")
        }
    }
    
    func updateCategoriesArray() -> [TaskCategory]? {
        
        guard let tasksCoreData = fetchAllTasks() else {
            return nil
        }
        
        var categories: [TaskCategory] = []
        
        for task in tasksCoreData {
            
            if let convertedTask = convertCoreDataToTask(task) {
                
                if !categories.isEmpty, categories.contains(where: { element in
                    element.titleOfCategory == task.taskCategory?.titleOfCategory
                }) {
                    
                    for index in 0..<categories.count {
                        
                        if categories[index].titleOfCategory == task.taskCategory?.titleOfCategory {
                            
                            var tasks: [TaskData] = categories[index].tasksArray
                            tasks.append(convertedTask)
                            
                            categories[index] = TaskCategory(titleOfCategory: categories[index].titleOfCategory, tasksArray: tasks)
                        }
                    }
                } else {
                    
                    categories.append(TaskCategory(titleOfCategory: task.taskCategory?.titleOfCategory ?? "", tasksArray: [convertedTask]))
                }
            }
        }
        
        return categories.sorted(by: { $0.titleOfCategory < $1.titleOfCategory })
    }
}

extension TaskStore: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard
            let taskCoreData = anObject as? TaskCoreData,
            let task = convertCoreDataToTask(taskCoreData)
        else { return }
        
        switch type {
            
        case .insert:
            if let title = taskCoreData.taskCategory?.titleOfCategory {
                delegate?.didAdd(task: task, with: title)
            }
            
        case .delete:
            delegate?.didDelete(task: task)
            
        case .update:
            if let title = taskCoreData.taskCategory?.titleOfCategory {
                delegate?.didUpdate(task: task, categoryTitle: title)
            }
        default:
            break
        }
    }
}
