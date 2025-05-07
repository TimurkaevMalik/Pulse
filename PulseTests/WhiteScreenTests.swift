//
//  TrackerTests.swift
//  PulseTests
//
//  Created by Malik Timurkaev on 27.05.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class WhiteScreenTests: XCTestCase {

    let viewController = TabBarControler()
    
    func testTrackersWasntFound() {
        
        UserDefaultsManager.chosenFilter = "completedOnes"
        
        assertSnapshot(matching: viewController, as: .image)
    }
    
    func testZeroTrackers() {
        
        UserDefaultsManager.chosenFilter = "allTasks"
        
        assertSnapshot(matching: viewController, as: .image)
    }
}
