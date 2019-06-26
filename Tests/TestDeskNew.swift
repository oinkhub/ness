import XCTest
@testable import Ness

final class TestDeskNew: XCTestCase {
    private var desk: Desk!
    
    override func setUp() {
        desk = .New()
    }
    
    func testCloseEmpty() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.desk.close(error: { _ in }) {
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
            self.desk.close(error: { _ in
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }) { }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveNew() {
        let expect = expectation(description: "")
        desk.content = "hello world"
        DispatchQueue.global(qos: .background).async {
            self.desk.save("newfile.txt", error: { _ in }) {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt").path, $0.path)
                XCTAssertEqual("hello world", try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt")), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
