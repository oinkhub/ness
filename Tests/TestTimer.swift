import XCTest
@testable import Ness

final class TestTimer: XCTestCase {
    override func setUp() {
        try! FileManager.default.createDirectory(at: Desk.url, withIntermediateDirectories: true)
        Desk.timeout = 0
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Desk.url)
    }
    
    func testSave() {
        let expect = expectation(description: "")
        let desk = Desk.new()
        desk.update("change")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertEqual("change", try? String(decoding: Data(contentsOf: desk.url), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateFile() {
        let expect = expectation(description: "")
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! Data("hello world".utf8).write(to: url)
        var desk: Desk!
        Desk.load(url) {
            desk = $0
            desk.update("lorem ipsum")
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
                XCTAssertEqual("lorem ipsum", try? String(decoding: Data(contentsOf: url), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileWithCache() {
        let expect = expectation(description: "")
        let desk = Desk.new()
        desk.update("change")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertNotNil(try? String(decoding: Data(contentsOf: desk.url), as: UTF8.self))
            desk.name("newfile.txt") { _ in
                XCTAssertEqual("change", try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt")), as: UTF8.self))
                XCTAssertNil(try? String(decoding: Data(contentsOf: desk.url), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
