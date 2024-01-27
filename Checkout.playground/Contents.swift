import Foundation
import XCTest

class Checkout {
    
    var total = 0
    
    func scan(_ product: String) {
        if product == "A" {
            total = 50
        }
    }

}

class CheckoutTests: XCTestCase {
    
    let co: Checkout = Checkout()

    func testEmpty() {
        XCTAssertEqual(0, co.total)
    }
    
    func testOne() {
        co.scan("A")
        XCTAssertEqual(50, co.total)
    }
    
}

CheckoutTests.defaultTestSuite.run()
