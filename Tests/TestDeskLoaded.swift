import XCTest
@testable import Ness

final class TestDeskLoaded: XCTestCase {
    private var url: URL!
    private var desk: Desk!
    private var dir: URL!
    
    override func setUp() {
        dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("dir")
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
        url = dir.appendingPathComponent(UUID().uuidString)
        try! Data("hello world".utf8).write(to: url)
        try! FileManager.default.createDirectory(at: Desk.url, withIntermediateDirectories: true)
        Desk.timeout = 0
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: dir)
        try! FileManager.default.removeItem(at: Desk.url)
    }
    
    func testLoadContent() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            Desk.load(self.url) {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual("hello world", $0.content)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCloseChanged() {
        let expect = expectation(description: "")
        Desk.load(url) {
            self.desk = $0
            self.desk.update("updated text")
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
                XCTAssertEqual("updated text", try? String(decoding: Data(contentsOf: self.url), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSave() {
        let expect = expectation(description: "")
        let new = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        Desk.load(url) {
            self.desk = $0
            self.desk.save(new) {
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.path))
                XCTAssertEqual("hello world", try? String(decoding: Data(contentsOf: new), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveAfterDeleteFolder() {
        let expect = expectation(description: "")
        Desk.load(url) {
            self.desk = $0
            try! FileManager.default.removeItem(at: self.dir)
            self.desk.update("updated text")
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
                XCTAssertEqual("updated text", try? String(decoding: Data(contentsOf: self.url), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
