//
//  TrackerType.swift
//  Pulse
//
//  Created by Malik Timurkaev on 16.05.2024.
//

import Foundation

enum ActionType {
    case create(value: TrackerType)
    case edit(value: TrackerType)
}

enum TrackerType {
    case habbit
    case irregularEvent
}
