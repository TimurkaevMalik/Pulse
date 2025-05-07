//
//  TaskToEdit.swift
//  Pulse
//
//  Created by Malik Timurkaev on 30.05.2024.
//

import UIKit

struct TaskToEdit {
    
    let titleOfCategory: String
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [String?]
    let daysCount: String
}
