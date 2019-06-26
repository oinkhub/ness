import XCTest
@testable import Ness

final class TestDesk: XCTestCase {
    private var desk: Desk!
    
    override func setUp() {
        desk = .New()
    }
    
    func testUpdateContent() {
        XCTAssertFalse(desk.changed)
        desk.content = "hello world"
        XCTAssertTrue(desk.changed)
    }
}
