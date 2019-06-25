import XCTest
@testable import Ness

final class TestPage: XCTestCase {
    private var page: Page!
    
    override func setUp() {
        page = Page()
    }
    
    func testUpdateContent() {
        XCTAssertEqual(.empty, page.status)
        page.content = "hello world"
        XCTAssertEqual(.changed, page.status)
    }
}
