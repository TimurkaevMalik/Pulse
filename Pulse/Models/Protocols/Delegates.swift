//
//  Protocols.swift
//  Pulse
//
//  Created by Malik Timurkaev on 12.04.2024.
//

import UIKit


protocol TaskStoreDelegate: AnyObject {
    func didUpdate(task: TaskData, categoryTitle: String)
    func didDelete(task: TaskData)
    func didAdd(task: TaskData, with categoryTitle: String)
}

protocol CategoryStoreDelegate: AnyObject {
    func didStoreCategory(_ category: TaskCategory)
    func storeDidUpdate(category: TaskCategory)
}

protocol RecordStoreDelegate: AnyObject {
    func didUpdate(record: TaskRecord)
    func didDelete(record: TaskRecord)
    func didAdd(record: TaskRecord)
}

protocol TabBarControllerDelegate: AnyObject {
    func hideFilterButton()
    func showFilterButton()
}

protocol PulseViewControllerDelegate: AnyObject {
    func dismisTaskTypeController()
    func addNewTask(taskCategory: TaskCategory)
    func didEditTask(task: TaskToEdit)
}


protocol FilterControllerDelegate: AnyObject {
    func didChooseFilter()
}

protocol ScheduleOfTaskDelegate: AnyObject {
    func didRecieveDatesArray(dates: [String])
    func didDismissScreenWithChanges(dates: [String])
}

protocol CategoryModelDelegate: AnyObject {
    func didChooseCategory(_ category: String)
    func didDismissScreenWithChangesIn(_ category: String?)
}

protocol NewCategoryViewProtocol: AnyObject {
    func categoryAlreadyExists()
    func didStoreNewCategory()
}

protocol CollectionViewCellDelegate: AnyObject {
    func contextMenuForCell(_ cell: CollectionViewCell) -> UIContextMenuConfiguration?
    func pinMenuButtonTappedOn(_ indexPath: IndexPath)
    func unpinMenuButtonTappedOn(_ indexPath: IndexPath)
    func editMenuButtonTappedOn(_ indexPath: IndexPath)
    func deleteMenuButtonTappedOn(_ indexPath: IndexPath)
    func cellPlusButtonTapped(_ cell: CollectionViewCell)
}
