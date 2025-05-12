import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        viewController.loadViewIfNeeded() // Ensure outlets are connected
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewController = nil
    }

    func testOutletsAreConnected() {
        XCTAssertNotNil(viewController.firstNameTextField, "firstNameTextField should not be nil")
        XCTAssertNotNil(viewController.lastNameTextField, "lastNameTextField should not be nil")
        XCTAssertNotNil(viewController.schoolTextField, "schoolTextField should not be nil")
        XCTAssertNotNil(viewController.yearSegmentedControl, "yearSegmentedControl should not be nil")
        XCTAssertNotNil(viewController.numberOfPetsLabel, "numberOfPetsLabel should not be nil")
        XCTAssertNotNil(viewController.morePetsSwitch, "morePetsSwitch should not be nil")
        XCTAssertNotNil(viewController.morePetsStepper, "morePetsStepper should not be nil")
    }

    func testStepperDidChange() {
        // Given
        let initialValue = viewController.morePetsStepper.value
        let newValue: Double = 5

        // When
        viewController.morePetsStepper.value = newValue
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, String(Int(newValue)), "numberOfPetsLabel should update to stepper value")

        // Reset to initial value for other tests
        viewController.morePetsStepper.value = initialValue
        viewController.stepperDidChange(viewController.morePetsStepper)
    }

    func testIntroduceSelfDidTapped_withValidData() {
        // Given
        viewController.firstNameTextField.text = "John"
        viewController.lastNameTextField.text = "Doe"
        viewController.schoolTextField.text = "CodePath University"
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Freshman
        viewController.numberOfPetsLabel.text = "2"
        viewController.morePetsSwitch.isOn = true

        // Create an expectation for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Override the present function to check the alert
        viewController.presentingViewController = MockViewController() // Required to avoid a crash when presenting from a test
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be correct")
            XCTAssertEqual(alertController.message, "My name is John Doe and I attend CodePath University. I am currently in my 1st year and I own 2 dogs. It is true that I want more pets.", "Alert message should be correct")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Alert action title should be correct")
            expectation.fulfill()
            completion?()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 2.0)
    }

    func testIntroduceSelfDidTapped_withEmptyData() {
        // Given
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Freshman
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Override the present function to check the alert
        viewController.presentingViewController = MockViewController() // Required to avoid a crash when presenting from a test
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be correct")
            XCTAssertEqual(alertController.message, "My name is   and I attend . I am currently in my 1st year and I own 0 dogs. It is false that I want more pets.", "Alert message should be correct")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Alert action title should be correct")
            expectation.fulfill()
            completion?()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 2.0)
    }

    func testIntroduceSelfDidTapped_differentYearSegment() {
        // Given
        viewController.firstNameTextField.text = "Jane"
        viewController.lastNameTextField.text = "Smith"
        viewController.schoolTextField.text = "Another University"
        viewController.yearSegmentedControl.selectedSegmentIndex = 3 // Senior
        viewController.numberOfPetsLabel.text = "1"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Override the present function to check the alert
        viewController.presentingViewController = MockViewController() // Required to avoid a crash when presenting from a test
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be correct")
            XCTAssertEqual(alertController.message, "My name is Jane Smith and I attend Another University. I am currently in my 4th year and I own 1 dogs. It is false that I want more pets.", "Alert message should be correct")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Alert action title should be correct")
            expectation.fulfill()
            completion?()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 2.0)
    }

    // Mock ViewController to avoid "whose view is not in the window hierarchy" error
    class MockViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    }
}

// Extend ViewController to override present for testing purposes
extension ViewController {
    typealias AlertPresentationCompletion = (() -> Void)?
    var present: ((UIAlertController, Bool, AlertPresentationCompletion) -> Void)! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.presentKey) as? ((UIAlertController, Bool, AlertPresentationCompletion) -> Void)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.presentKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    private struct AssociatedKeys {
        static var presentKey: UInt8 = 0
    }
}

import ObjectiveC
