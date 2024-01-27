import Foundation
import XCTest

class Checkout {
    
    let total = 0
    
    func scan(_ product: String) {
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
