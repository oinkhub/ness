import XCTest
@testable import Ness

final class TestDesk: XCTestCase {
    private var desk: Desk!
    
    override func setUp() {
        desk = Desk()
    }
    
    func testUpdateContent() {
        XCTAssertFalse(desk.changed)
        desk.content = "hello world"
        XCTAssertTrue(desk.changed)
    }
    
    func testCloseEmpty() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.desk.close({ }) {
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCloseChanged() {
        let expect = expectation(description: "")
        desk.content = "hello world"
        DispatchQueue.global(qos: .background).async {
            self.desk.close({
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }) { }
        }
        waitForExpectations(timeout: 1)
    }
}
