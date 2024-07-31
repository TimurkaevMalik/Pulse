//
//  BlackScreenTests.swift
//  TrackerTests
//
//  Created by Malik Timurkaev on 02.06.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker


final class BlackScreenTests: XCTestCase {
    
    let viewController = TabBarControler()
    
    func testBlackScreenTrackersWasntFound() {
        
        UserDefaultsManager.chosenFilter = "completedOnes"
        
        assertSnapshot(matching: viewController, as: .image)
    }
    
    func testBlackScreenZeroTrackers() {
        
        UserDefaultsManager.chosenFilter = "allTrackers"
        
        assertSnapshot(matching: viewController, as: .image)
    }
}
