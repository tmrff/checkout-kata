# Solution for Kata 9, Checkout.


## TDD Process

### Empty Case Test

First, I wrote the initial test for the empty case.

    XCTAssertEqual(0, co.total)

The test fails because I haven't implemented the Checkout yet so let's do that.  I do the minimum required to get the test to pass. 

    class Checkout {
	    let total = 0
    }
   
### "A" Test

Next I write the second test.

    func testOne() {
        co.scan("A")
        XCTAssertEqual(50, co.total)
    }
    
This one fails because the `scan` function looks like this:

    func scan(_ product: String) {}
    

Let's implement it. Yay, it passes.

    func scan(_ product: String) {
        if product == "A" {
            total = 50
        }
    }


### "AB" Test

Next test:

    func testTwo() {
        co.scan("A")
        co.scan("B")
        XCTAssertEqual(80, co.total)
    }
    
This test fails because our `scan` function is hard coded to return 50. A simple way to make this pass would be to add `else total = 30` but I think it's refactoring time.

*Coming back to this I noticed I did not articulate why I chose to create a dictionary and pass it into Checkout as a dependency.
If I was to do this exercise again I would not abstract prices out of Checkout. Instead I'd leave that logic in the scan method as said above. KISS.* 

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

I add a dictionary property to `Checkout`. This dictionary will store product as key and the price for the product as value. If I need a key value store data structure dictionary is hard to beat.

Within the test class's `setUp` function I pass a prices dictionary into the `Checkout` instance.

      override func setUp() {
        super.setUp()
        let prices = ["A": 50, "B": 30]
        co = Checkout(prices)
    }

Now the test is passing.

### "CDBA" Test

The next test includes some unseen products so it fails:

     func testFour() {
        co.scan("C")
        co.scan("D")
        co.scan("B")
        co.scan("A")
        XCTAssertEqual(115, co.total)
    }

To make this test pass is easy, just add `C` and `D` and their associated price to the prices dictionary.

    let prices = ["A": 50, "B": 30, "C": 20, "D": 15]

### "AA" Test

Next test: 

    func testTwoSame() {
	    price("AA")
	    XCTAssertEqual(100, co.total)
	}

But before that I want to add a helper method adapted from the kata document. Iterate Over the characters in a string representing the products and scan each one.
	
	// Checkout.swift
	
     func price(_ products: String) {
        for product in products {
            co.scan(String(product))
        }
     }

Now update the tests to call into this method:

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

Back to our failing test

     func testTwoSame() {
	    price("AA")
	    XCTAssertEqual(100, co.total)
	}

And it passes without failing.  Why? Because we already have entry in our dictionary for `"A"`. 


### "AAA" Test

This next test is where we see our first discount. The checkout logic needs to know about this. It fails as expected.

    func testThreeSame()  {
		price("AAA")
		XCTAssertEqual(130, co.total)
	}

How can we code this discount?

The rule is: `buy 3 A pay 130`

We will keep track of how many times `A` appears by comparing `"A"` literal with each iteration over the characters in the string.

The mod operator `%` comes to mind here, but because this test includes only 3, it is not required yet.  Instead we will do the following: 

Once the counter reaches three, we apply the discount to the total.

    // Checkout.swift
    
    var aCounter = 0
    
    if product == "A" {
	    aCounter += 1
        if aCounter == 3 {
	        total = total - 20
        }
    }

The next test passes without need for modifying the code:

    func testFourSame() {
        price("AAAA")
        XCTAssertEqual(180, co.total)
    }
    
	 func testFiveSame() {
        price("AAAAA")
        XCTAssertEqual(230, co.total)
    }

### "AAAAAA" Test

Now this test fails:

     func testSixSame() {
        price("AAAAAA")
        XCTAssertEqual(260, co.total)
    }

The problem is the Checkout is only applying the discount when the counter equals 3 but here we need to account for more than one discount.

We can apply this rule using the mod operator.

    if aCounter % 3 == 0 {
	    total = total - 20
    }

This test passes automatically

    func testAAAB() {
        price("AAAB")
        XCTAssertEqual(160, co.total)
    }

### "AAABB" Test

This test fails because we need to account for B having a discount.

    func testAAABB() {
        price("AAABB")
        XCTAssertEqual(175, co.total)
    }

The rule is: `buy 2 B pay 45`

Let's do the same thing we did for A and code the discount logic into the scan function. 


We can add another property to `Checkout`, named `bCounter`, and add a condition inside the loop that checks for `B`. For example, `if bCounter % 2 == 0`, then apply a discount of 15.


	// Checkout.swift
	
    var bCounter = 0

	func scan(_ product: String) {

		if product == "A" { ... }

	    if product == "B" {
		     bCounter += 1
		     if bCounter % 2 == 0 {
		         total = total - 15
	        }
	     }
    }


![Checkout Class Diagram](https://diagrams.helpful.dev/d/d:a7FiLSqU)


Nice now our test is passing.

The next test passing without modification:

    func DABABA() {
        price("DABABA")
        XCTAssertEqual(190, co.total)
    }


And the final test also passes without modification:

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

## Enhancements

As it stands, the checkout is responsible for knowing each product and its discount rules. These are hard coded into the `scan` function. A possible code smell.

We can refer to the single responsibility principle and realise we can do a little better than this. Let's decouple.

Let's refactor and then lean on our set of tests to ensure it behaves as we expect.

### Calculate Discount Function

We can extract this discount logic out of the `scan` function and even out of the `Checkout` to make it more flexible.

Let's start by extracting the discount logic from the `scan` function and into a new function, which we will call `calculateDiscounts`

    // Checkout.swift

	var productCounters: [String: Int] = [:]    

    func calculateDiscount(for product: String) -> Int {
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

     func scan(_ product: String) {
        if let price = prices[product] {
            total += price
            total -= calculateDiscounts(for: product)
        }
    }



I've added a dictionary property  `var productCounters: [String: Int]` to Checkout that will be used by calculateDiscounts function to store and retrieve how many times a type of product is scanned. 

We could use a product counter variable for each product but I used a dictionary here because I think it is cleaner.

![Checkout Class Diagram](https://diagrams.helpful.dev/d/d:m56xg79B)


Ok it's looking better now but we can go further if we needed. This would be needed if the discount rules become complex. 

### Discount Manager 

For example we might need to account for different types of discounts e.g. a supermarket club card. Making the distinct component seperate will make it simpler and easier to reason about.

![Class Diagram](https://diagrams.helpful.dev/d/d:h2i7dC8l)

Extracting the `calculateDiscounts` function it's own class:


	// DiscountManager.swift
	
    class DiscountManager {
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
   

And after this refactor I run the tests to confirm the behavior. Ok so now we have done this work of separating out the classes lets make use of it by introducing a protocol. 

By hiding the inner workings of `DiscountManager` behind a protocol we can switch out the implementation with other types of DiscountManagers that conform to the same API.

A benefit of this protocol is we can now test `Checkout` independently from `DiscountManager`.  We can do this by creating a mock class that conforms to the protocol.

First we will define the protocol:

    protocol DiscountManagerProtocol {
	    func calculateDiscounts(for product: String) -> Int
    }

Then make our DiscountManager conform. It already complies so no error: 

    class DiscountManager: DiscountManagerProtocol { ... }


Define the mock discount manager class:

    class MockDiscountManager: DiscountManagerProtocol {
    
	    var mockDiscounts = [String: Int]()

	    func calculateDiscounts(for product: String) -> Int 	{
	        return mockDiscounts[product, default: 0]
	    }
    }

Next we need to remove the line in Checkout that instantiates its own DiscountManager.

Then we add code to inject an instance of discount manager:

    // Checkout.swift
    
    private var discountManager: DiscountManagerProtocol
    
    init(_ prices: [String: Int], discountManager: DiscountManagerProtocol) {
        self.prices = prices
        self.discountManager = discountManager
    }

Now if we like we can substitute `DiscountManager` for `MockDiscountManager` when testing `Checkout` logic.


## Take Two

*Coming back to this I'm noticing more improvements I could make. I will roll back the discount manager class. The logic is not complex enough at this stage to warrant it.*

Some improvements:
	- Use enum for Product code type
	- Encapsulate discount logic into its own struct `BulkDiscountRule` w/ protocol `DiscountRule`.
	- 

First of all right now we have the product code type as a string. Let's use Enums! We can conform to `String` protocol and use `ProductCode.rawValue()` to get a string representation.

    enum ProductCode: String {
    	 case  A, B, C, D
    }


`DiscountRule` is a protocol that defines a single function `func calculateDiscount`. This function takes a `ProductCode` and an Int (representing the count of the product) and returns an Int (the discount amount). 

`DiscountRule` protocol can be used if we want to add different discount types in the future.


    protocol DiscountRule {
	    func calculateDiscount(for product: ProductCode, count: Int) -> Int
    }
    
    struct BulkDiscountRule: DiscountRule {
	    var threshold: Int
	    var discountAmount: Int

	    func calculateDiscount(for product: ProductCode, count: Int) -> Int {
	        return (count / threshold) * discountAmount
	    }
	}


`BulkDiscountRule` is what I've called the discounts we have described already (buy many of one type of product to get discount).

`Threshold`'s value is the same number that was on the right side of the mod operator earlier.

`BulkDiscountRule`  associates a product code e.g. `A` with a price rule. the price rule depends on the threshold (count) of the product and the discount amount.

Our Checkout is now a struct and performs the operation in a different way:

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


Properties of `Checkout` include:
	-  `prices`: A dictionary mapping each `ProductCode` its unit price.
	- `productCounts`: A dictionary that tracks the count of each product scanned.
	- `discountRules`: A dictionary mapping `ProductCode` to a corresponding discount rule. 

 `func scan` function takes a `ProductCode` as an input and Increments the count of the scanned product in the `productCounts` dictionary.
 
 If the product is scanned for the first time, it's added to the dictionary with a default count of 0 and then incremented.

 Total Calculation (`total` computed property):
    -   Iterates over each entry in `productCounts`.
    -   For each product, it retrieves the unit price and the discount (if any) applicable to the product.
    -   Calculates the total price for each product (unit price × quantity) and subtracts the discount.
    -   Summarises these values to compute the overall total cost of all scanned products.


When a product is scanned (using the `scan` method), the `Checkout` struct records this and updates the quantity of that product.
To get the total cost, the `total` computed property is accessed. It calculates the total considering all scanned items and any applicable discounts.

 
## Acknowledgements

[Kata 9: Checkout](http://codekata.com/kata/kata09-back-to-the-checkout/)


