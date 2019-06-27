import XCTest
@testable import Ness

final class TestDeskLoaded: XCTestCase {
    private var desk: Desk!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! Data("hello world".utf8).write(to: url)
    }
    
    override func tearDown() { try? FileManager.default.removeItem(at: url) }
    
    func testLoadContent() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.desk = .Loaded(self.url, error: { _ in }) {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual("hello world", self.desk.content)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadError() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.desk = .Loaded(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("invalid.file"), error: { _ in
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }) { }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCloseNoChange() {
        let expect = expectation(description: "")
        desk = .Loaded(url, error: { _ in }) {
            DispatchQueue.global(qos: .background).async {
                self.desk.close({ _ in }, error: { _ in }) {
                    XCTAssertEqual(.main, Thread.current)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCloseChanged() {
        let expect = expectation(description: "")
        desk = .Loaded(url, error: { _ in }) {
            self.desk.content = "updated text"
            self.desk.close({ _ in }, error: { _ in }) {
                XCTAssertEqual("updated text", try? String(decoding: Data(contentsOf: self.url), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
