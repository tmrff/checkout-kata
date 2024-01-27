import Foundation
import XCTest

class Checkout {
    
    let total = 0

}

class CheckoutTests: XCTestCase {
    
    let co: Checkout = Checkout()
   
    func testEmpty() {
        XCTAssertEqual(0, co.total)
    }
}

CheckoutTests.defaultTestSuite.run()
