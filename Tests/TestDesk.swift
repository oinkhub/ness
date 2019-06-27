import XCTest
@testable import Ness

final class TestDesk: XCTestCase {
    private var url: URL!
    private var desk: Desk!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cache")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func testUpdateContent() {
        desk = .New()
        XCTAssertFalse(desk.changed)
        desk.update("hello world")
        XCTAssertTrue(desk.changed)
    }
    
    func testEmpty() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.desk = .New {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual("", self.desk.content)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadWithCache() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url)
        desk = .New {
            XCTAssertEqual("hello world", self.desk.content)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveWithCacheNotEdited() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url)
        desk = .New {
            self.desk.close({ _ in
                expect.fulfill()
            }, error: { _ in }, done: { })
        }
        waitForExpectations(timeout: 1)
    }
}
