//
//  BlackScreenTests.swift
//  PulseTests
//
//  Created by Malik Timurkaev on 02.06.2024.
//

import XCTest
import SnapshotTesting
@testable import Pulse


final class BlackScreenTests: XCTestCase {
    
    let viewController = TabBarControler()
    
    func testBlackScreenTasksWasntFound() {
        
        UserDefaultsManager.chosenFilter = "completedOnes"
        
        assertSnapshot(matching: viewController, as: .image)
    }
    
    func testBlackScreenZeroTasks() {
        
        UserDefaultsManager.chosenFilter = "allTasks"
        
        assertSnapshot(matching: viewController, as: .image)
    }
}
