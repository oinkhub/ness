import XCTest
@testable import Ness

final class TestDeskNew: XCTestCase {
    override func setUp() {
        try! FileManager.default.createDirectory(at: Desk.url, withIntermediateDirectories: true)
        Desk.timeout = 0
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Desk.url)
    }
    
    func testCloseChanged() {
        let expect = expectation(description: "")
        let desk = Desk.new()
        desk.update("hello world")
        desk.name("newfile.txt") {
            XCTAssertEqual(.main, Thread.current)
            XCTAssertEqual(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt").path, $0.path)
            XCTAssertEqual("hello world", try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt")), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDifferentURL() {
        XCTAssertNotEqual(Desk.new().url.lastPathComponent, Desk.new().url.lastPathComponent)
    }
    
    func testDiscard() {
        let expect = expectation(description: "")
        let desk = Desk.new()
        desk.update("hello world")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertTrue(FileManager.default.fileExists(atPath: desk.url.path))
            desk.discard()
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
                XCTAssertFalse(FileManager.default.fileExists(atPath: desk.url.path))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
