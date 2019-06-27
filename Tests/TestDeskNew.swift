import XCTest
@testable import Ness

final class TestDeskNew: XCTestCase {
    func testCloseEmpty() {
        let expect = expectation(description: "")
        let desk = Desk.New()
        DispatchQueue.global(qos: .background).async {
            desk.close({ _ in }, error: { _ in }) {
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCloseChanged() {
        let expect = expectation(description: "")
        let desk = Desk.New()
        desk.update("hello world")
        DispatchQueue.global(qos: .background).async {
            desk.close({ name in
                XCTAssertEqual(.main, Thread.current)
                DispatchQueue.global(qos: .background).async {
                    name("newfile.txt") {
                        XCTAssertEqual(.main, Thread.current)
                        XCTAssertEqual(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt").path, $0.path)
                        XCTAssertEqual("hello world", try? String(decoding: Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("newfile.txt")), as: UTF8.self))
                        expect.fulfill()
                    }
                }
                
            }, error: { _ in }) { }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDifferentURL() {
        let expect = expectation(description: "")
        Desk.timeout = 0
        let deskA = Desk.New()
        deskA.update("hello world")
        let deskB = Desk.New()
        deskB.update("lorem ipsum")
        DispatchQueue.global(qos: .background).async {
            XCTAssertNotNil(deskA.url)
            XCTAssertNotNil(deskB.url)
            XCTAssertNotEqual(deskA.url?.lastPathComponent, deskB.url?.lastPathComponent)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
