import XCTest
@testable import Ness

final class TestSession: XCTestCase {
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: "session")
    }
    
    func testLoad() {
        let expect = expectation(description: "")
        let dateMin = Calendar.current.date(byAdding: {
            var d = DateComponents()
            d.day = 3
            return d
        } (), to: Date())!
        let dateMax = Calendar.current.date(byAdding: {
            var d = DateComponents()
            d.day = 4
            return d
        } (), to: Date())!
        DispatchQueue.global(qos: .background).async {
            Session.load {
                XCTAssertGreaterThanOrEqual($0.rating, dateMin)
                XCTAssertLessThan($0.rating, dateMax)
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadRating() {
        let expect = expectation(description: "")
        let date = Date()
        var session = Session()
        session.rating = date
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertEqual(date, $0.rating)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadSpell() {
        let expect = expectation(description: "")
        var session = Session()
        session.spell = true
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertTrue($0.spell)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadOnboard() {
        let expect = expectation(description: "")
        var session = Session()
        session.onboard = false
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertFalse($0.onboard)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadNumbers() {
        let expect = expectation(description: "")
        var session = Session()
        session.numbers = false
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertFalse($0.numbers)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadLine() {
        let expect = expectation(description: "")
        var session = Session()
        session.line = false
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertFalse($0.line)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadSize() {
        let expect = expectation(description: "")
        var session = Session()
        session.size = 20
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertEqual(20, $0.size)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReLoadFont() {
        let expect = expectation(description: "")
        var session = Session()
        session.font = .SanFrancisco
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            Session.load {
                XCTAssertEqual(.SanFrancisco, $0.font)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
