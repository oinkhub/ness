import XCTest
@testable import Ness

final class TestTimer: XCTestCase {
    private var desk: Desk!
    
    override func setUp() {
        Desk.timeout = 0
    }
    
    func testUpdateStatus() {
        let expect = expectation(description: "")
        desk = .New()
        XCTAssertFalse(desk.changed)
        desk.update("change")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertFalse(self.desk.changed)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveCache() {
        let expect = expectation(description: "")
        desk = .New()
        XCTAssertFalse(desk.changed)
        desk.update("change")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertEqual("change", try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cache")), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateFile() {
        let expect = expectation(description: "")
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! Data("hello world".utf8).write(to: url)
        desk = .Loaded(url, error: { _ in }) {
            XCTAssertFalse(self.desk.changed)
            self.desk.update("lorem ipsum")
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
                XCTAssertEqual("lorem ipsum", try? String(decoding: Data(contentsOf: url), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileWithCache() {
        let expect = expectation(description: "")
        desk = .New()
        XCTAssertFalse(desk.changed)
        desk.update("change")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertFalse(self.desk.changed)
            self.desk.close({ name in
                name("newfile.txt") { _ in
                    XCTAssertEqual("change", try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt")), as: UTF8.self))
                    XCTAssertNil(try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cache")), as: UTF8.self))
                    expect.fulfill()
                }
            }, error: { _ in }) { }
        }
        waitForExpectations(timeout: 1)
    }
}
