import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()
        // Instantiate the ViewController from the Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        
        // Ensure the view is loaded before running tests that access UI elements
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    // MARK: - IBOutlet Tests

    func testIBOutletConnections() {
        XCTAssertNotNil(viewController.firstNameTextField, "firstNameTextField should be connected")
        XCTAssertNotNil(viewController.lastNameTextField, "lastNameTextField should be connected")
        XCTAssertNotNil(viewController.schoolTextField, "schoolTextField should be connected")
        XCTAssertNotNil(viewController.yearSegmentedControl, "yearSegmentedControl should be connected")
        XCTAssertNotNil(viewController.numberOfPetsLabel, "numberOfPetsLabel should be connected")
        XCTAssertNotNil(viewController.morePetsSwitch, "morePetsSwitch should be connected")
        XCTAssertNotNil(viewController.morePetsStepper, "morePetsStepper should be connected")
    }

    // MARK: - IBAction Tests

    func testStepperDidChange() {
        // Given
        let initialValue = 5.0
        viewController.morePetsStepper.value = initialValue

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, String(Int(initialValue)), "numberOfPetsLabel should update with stepper value")
    }

    func testIntroduceSelfDidTapped_withValidInput() {
        // Given
        viewController.firstNameTextField.text = "John"
        viewController.lastNameTextField.text = "Doe"
        viewController.schoolTextField.text = "CodePath University"
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Freshman
        viewController.numberOfPetsLabel.text = "2"
        viewController.morePetsSwitch.isOn = true

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert presented")

        // Override the present function to check the alert
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be 'My Introduction'")
            XCTAssertEqual(alertController.message, "My name is John Doe and I attend CodePath University. I am currently in my Freshman year and I own 2 dogs. It is true that I want more pets.", "Alert message should match the input values")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Alert action title should be 'Nice to meet you!'")
            expectation.fulfill() // Fulfill the expectation when the alert is presented
            completion?() // Call the completion handler
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 5.0) // Wait for the expectation to be fulfilled
    }

    func testIntroduceSelfDidTapped_withEmptyInput() {
        // Given
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Freshman
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert presented")

        // Override the present function to check the alert
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be 'My Introduction'")
            XCTAssertEqual(alertController.message, "My name is   and I attend . I am currently in my Freshman year and I own 0 dogs. It is false that I want more pets.", "Alert message should match the input values")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Alert action title should be 'Nice to meet you!'")
            expectation.fulfill() // Fulfill the expectation when the alert is presented
            completion?() // Call the completion handler
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 5.0) // Wait for the expectation to be fulfilled
    }

    func testIntroduceSelfDidTapped_differentYear() {
        // Given
        viewController.firstNameTextField.text = "Jane"
        viewController.lastNameTextField.text = "Smith"
        viewController.schoolTextField.text = "Another University"
        viewController.yearSegmentedControl.selectedSegmentIndex = 3 // Senior
        viewController.numberOfPetsLabel.text = "1"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert presented")

        // Override the present function to check the alert
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.message, "My name is Jane Smith and I attend Another University. I am currently in my Senior year and I own 1 dogs. It is false that I want more pets.", "Alert message should match the input values")
            expectation.fulfill() // Fulfill the expectation when the alert is presented
            completion?() // Call the completion handler
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 5.0) // Wait for the expectation to be fulfilled
    }

    // MARK: - Helper

    // Mock the present function to verify the alert controller
    extension ViewController {
        typealias PresentCompletion = (() -> Void)?
        var present: ((UIAlertController, Bool, PresentCompletion) -> Void)? {
            get {
                return objc_getAssociatedObject(self, &AssociatedKeys.presentKey) as? ((UIAlertController, Bool, PresentCompletion) -> Void)
            }
            set {
                objc_setAssociatedObject(self, &AssociatedKeys.presentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    private struct AssociatedKeys {
        static var presentKey: UInt8 = 0
    }

    import ObjectiveC
}
