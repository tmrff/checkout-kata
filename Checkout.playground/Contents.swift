import Foundation
import XCTest

class Checkout {
    
    var total = 0
    var prices: [String: Int]
    var aCounter = 0
    
    init(_ prices: [String: Int]) {
        self.prices = prices
    }
    
    func scan(_ product: String) {
        if let price = prices[product] {
            total += price
            
            if product == "A" {
                aCounter += 1
                if aCounter % 3 == 0 {
                    total = total - 20
                }
            }
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
    
    func testTwoSame() {
        price("AA")
        XCTAssertEqual(100, co.total)
    }
    
    func testThreeSame() {
        price("AAA")
        XCTAssertEqual(130, co.total)
    }
    
    func testFourSame() {
        price("AAAA")
        XCTAssertEqual(180, co.total)
    }
    
    func testFiveSame() {
        price("AAAAA")
        XCTAssertEqual(230, co.total)
    }
    
    func testSixSame() {
        price("AAAAAA")
        XCTAssertEqual(260, co.total)
    }
    
    func testAAAB() {
        price("AAAB")
        XCTAssertEqual(160, co.total)
    }
    
    func testAAABB() {
        price("AAABB")
        XCTAssertEqual(175, co.total)
    }
    
}

CheckoutTests.defaultTestSuite.run()
