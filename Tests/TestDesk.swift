import XCTest
@testable import Ness

final class TestDesk: XCTestCase {
    override func setUp() {
        try! FileManager.default.createDirectory(at: Desk.url, withIntermediateDirectories: true)
        Desk.timeout = 0
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Desk.url)
    }
    
    func testEmpty() {
        XCTAssertTrue(Desk.new().cached)
    }
    
    func testLoadWithCache() {
        try! Data("First file".utf8).write(to: Desk.url.appendingPathComponent("a"))
        try! Data("Second file".utf8).write(to: Desk.url.appendingPathComponent("b"))
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            Desk.cache {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual(2, $0.count)
                XCTAssertTrue($0.first!.cached)
                XCTAssertEqual("First file", $0.first?.content)
                XCTAssertEqual("Second file", $0.last?.content)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadNoCache() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            Desk.cache {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual(1, $0.count)
                XCTAssertTrue($0.first!.cached)
                XCTAssertEqual("", $0.first?.content)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
