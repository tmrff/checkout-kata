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
    
    func price(_ products: String) {
        for product in products {
            co.scan(String(product))
        }
    }
    
    override func setUp() {
        super.setUp()
        let prices = ["A": 50, "B": 30, "C": 20, "D": 15]
        co = Checkout(prices)
    }

    func testEmpty() {
        XCTAssertEqual(0, co.total)
    }
    
    func testOne() {
        price("A")
        XCTAssertEqual(50, co.total)
    }
    
    func testTwo() {
        price("AB")
        XCTAssertEqual(80, co.total)
    }
    
    func testFour() {
        price("CDBA")
        XCTAssertEqual(115, co.total)
    }
    
}

CheckoutTests.defaultTestSuite.run()
