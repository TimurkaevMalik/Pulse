//
//  TrackerTests.swift
//  PulseTests
//
//  Created by Malik Timurkaev on 27.05.2024.
//

import XCTest
import SnapshotTesting
@testable import Pulse

final class WhiteScreenTests: XCTestCase {

    let viewController = TabBarControler()
    
    func testTasksWasntFound() {
        
        UserDefaultsManager.chosenFilter = "completedOnes"
        
        assertSnapshot(matching: viewController, as: .image)
    }
    
    func testZeroTasks() {
        
        UserDefaultsManager.chosenFilter = "allTasks"
        
        assertSnapshot(matching: viewController, as: .image)
    }
}
