import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackersViewControllerSnapshots: XCTestCase {
    private var subject: TrackerViewController!
    
    override func setUp() {
        super.setUp()
        subject = .init()
    }
    
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func testLightSnapshot() throws {
        let embeddedController = UINavigationController(rootViewController: subject)
        
        assertSnapshot(
            matching: embeddedController,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testDarkSnapshot() throws {
        let embeddedController = UINavigationController(rootViewController: subject)
        
        assertSnapshot(
            matching: embeddedController,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
