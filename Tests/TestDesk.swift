import XCTest
@testable import Ness

final class TestDesk: XCTestCase {
    private var desk: Desk!
    
    override func setUp() {
        desk = Desk()
    }
    
    func testOpenEmpty() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.desk.open({ _ in }) {
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOpenChanged() {
        let expect = expectation(description: "")
        desk.page.content = "hello world"
        DispatchQueue.global(qos: .background).async {
            self.desk.open({ _ in
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }) { }
        }
        waitForExpectations(timeout: 1)
    }
}
