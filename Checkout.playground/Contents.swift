import Foundation
import XCTest

class CheckoutTests: XCTestCase {
    
    let co: Checkout = Checkout()
   
    func testEmpty() {
        XCTAssertEqual(0, co.total)
    }
}

CheckoutTests.defaultTestSuite.run()
