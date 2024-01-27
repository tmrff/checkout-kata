import Foundation
import XCTest

class Checkout {
    
    var total = 0
    var prices: [String: Int]
    
    init(_ prices: [String: Int]) {
        self.prices = prices
    }
    
    func scan(_ product: String) {
        if let price = prices[product] {
            total += price
        }
    }

}

class CheckoutTests: XCTestCase {
    var co: Checkout!
    
    override func setUp() {
        super.setUp()
        let prices = ["A": 50, "B": 30, "C": 20, "D": 15]
        co = Checkout(prices)
    }

    func testEmpty() {
        XCTAssertEqual(0, co.total)
    }
    
    func testOne() {
        co.scan("A")
        XCTAssertEqual(50, co.total)
    }
    
    func testTwo() {
        co.scan("A")
        co.scan("B")
        XCTAssertEqual(80, co.total)
    }
    
    func testFour() {
        co.scan("C")
        co.scan("D")
        co.scan("B")
        co.scan("A")
        XCTAssertEqual(115, co.total)
    }
    
}

CheckoutTests.defaultTestSuite.run()
