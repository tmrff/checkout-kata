import Foundation
import XCTest

enum ProductCode: String {
    case A, B, C, D
}

protocol DiscountRule {
    func calculateDiscount(for product: ProductCode, count: Int) -> Int
}

struct BulkDiscountRule: DiscountRule {
    var threshold: Int
    var discountAmount: Int
    
    func calculateDiscount(for product: ProductCode, count: Int) -> Int {
        (count / threshold) * discountAmount
    }
}

struct Checkout {
    private var prices: [ProductCode: Int]
    private var productCounts = [ProductCode: Int]()
    private var discountRules: [ProductCode: DiscountRule]
    
    init(prices: [ProductCode: Int], discountRules: [ProductCode: DiscountRule]) {
        self.prices = prices
        self.discountRules = discountRules
    }
    
    mutating func scan(_ productCode: ProductCode) {
        productCounts[productCode, default: 0] += 1
    }
    
    var total: Int {
        var total = 0
        for (product, count) in productCounts {
            let price = prices[product] ?? 0
            let discount = discountRules[product]?.calculateDiscount(for: product, count: count) ?? 0
            total += (price * count) - discount
        }
        return total
    }
}

class CheckoutTests: XCTestCase {
    var co: Checkout!
    
    override func setUp() {
        super.setUp()
        let prices = [ProductCode.A: 50, .B: 30, .C: 20, .D: 15]
        let discountRules = [ProductCode.A: BulkDiscountRule(threshold: 3, discountAmount: 20),
                             .B: BulkDiscountRule(threshold: 2, discountAmount: 15)]
        co = Checkout(prices: prices, discountRules: discountRules)
    }
    
    func testEmpty() {
        XCTAssertEqual(0, co.total)
    }
    
    func testOne() {
        co.scan(.A)
        XCTAssertEqual(50, co.total)
    }
    
    func testTwo() {
        co.scan(.A)
        co.scan(.B)
        XCTAssertEqual(80, co.total)
    }
    
    func testFour() {
        co.scan(.C)
        co.scan(.D)
        co.scan(.B)
        co.scan(.A)
        XCTAssertEqual(115, co.total)
    }
    
    func testTwoSame() {
        co.scan(.A)
        co.scan(.A)
        XCTAssertEqual(100, co.total)
    }
    
    func testThreeSame() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        XCTAssertEqual(130, co.total)
    }
    
    func testFourSame() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        XCTAssertEqual(180, co.total)
    }
    
    func testFiveSame() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        XCTAssertEqual(230, co.total)
    }
    
    func testSixSame() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        XCTAssertEqual(260, co.total)
    }
    
    func testAAAB() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.B)
        XCTAssertEqual(160, co.total)
    }
    
    func testAAABB() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.B)
        co.scan(.B)
        XCTAssertEqual(175, co.total)
    }
    
    func testAAABBD() {
        co.scan(.A)
        co.scan(.A)
        co.scan(.A)
        co.scan(.B)
        co.scan(.B)
        co.scan(.D)
        XCTAssertEqual(190, co.total)
    }
    
    func testDABABA() {
        co.scan(.D)
        co.scan(.A)
        co.scan(.B)
        co.scan(.A)
        co.scan(.B)
        co.scan(.A)
        XCTAssertEqual(190, co.total)
    }
    
    func testIncremental() {
        XCTAssertEqual(co.total, 0)
        
        co.scan(.A)
        XCTAssertEqual(co.total, 50)
        
        co.scan(.B)
        XCTAssertEqual(co.total, 80)
        
        co.scan(.A)
        XCTAssertEqual(co.total, 130)
        
        co.scan(.A)
        XCTAssertEqual(co.total, 160)
        
        co.scan(.B)
        XCTAssertEqual(co.total, 175)
    }
    
}

CheckoutTests.defaultTestSuite.run()
