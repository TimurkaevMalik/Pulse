//
//  TaskType.swift
//  Pulse
//
//  Created by Malik Timurkaev on 16.05.2024.
//

import Foundation

enum ActionType {
    case create(value: TaskType)
    case edit(value: TaskType)
}

enum TaskType {
    case habbit
    case irregularEvent
}
