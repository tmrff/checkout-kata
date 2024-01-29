import Foundation
import XCTest

class Checkout {
    
    var total = 0
    private var prices: [String: Int]
    private var discountManager: DiscountManagerProtocol
    
    init(_ prices: [String: Int], discountManager: DiscountManagerProtocol) {
        self.prices = prices
        self.discountManager = discountManager
    }
    
    func scan(_ product: String) {
        if let price = prices[product] {
            total += price
            total -= discountManager.calculateDiscounts(for: product)
        }
    }
}


class DiscountManager: DiscountManagerProtocol {
    private var productCounters: [String: Int] = [:]
    
    func calculateDiscounts(for product: String) -> Int {
        // Increment the frequency counter for the scanned product
        productCounters[product, default: 0] += 1
        
        switch product {
        case "A":
            if productCounters[product]! % 3 == 0 {
                return 20
            }
        case "B":
            if productCounters[product]! % 2 == 0 {
                return 15
            }
        default:
            break
        }
        
        return 0
    }
}

protocol DiscountManagerProtocol {
    func calculateDiscounts(for product: String) -> Int
}

class MockDiscountManager: DiscountManagerProtocol {
    var mockDiscounts = [String: Int]()

    func calculateDiscounts(for product: String) -> Int {
        return mockDiscounts[product, default: 0]
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
        let mockDiscountManager = MockDiscountManager()
        co = Checkout(prices, discountManager: mockDiscountManager)
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
    
    func AAABBD() {
        price("AAABBD")
        XCTAssertEqual(190, co.total)
    }
    
    func DABABA() {
        price("DABABA")
        XCTAssertEqual(190, co.total)
    }
    
    func testIncremental() {
        XCTAssertEqual(co.total, 0)
        
        co.scan("A")
        XCTAssertEqual(co.total, 50)
        
        co.scan("B")
        XCTAssertEqual(co.total, 80)
        
        co.scan("A")
        XCTAssertEqual(co.total, 130)
        
        co.scan("A")
        XCTAssertEqual(co.total, 160)
        
        co.scan("B")
        XCTAssertEqual(co.total, 175)
    }
    
}

CheckoutTests.defaultTestSuite.run()
