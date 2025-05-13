import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        // Instantiate the storyboard and ViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        
        // Load the view to trigger IBOutlets to connect
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    // MARK: - IBOutlet Tests

    func testIBOutletsAreConnected() {
        XCTAssertNotNil(viewController.firstNameTextField, "firstNameTextField should be connected")
        XCTAssertNotNil(viewController.lastNameTextField, "lastNameTextField should be connected")
        XCTAssertNotNil(viewController.schoolTextField, "schoolTextField should be connected")
        XCTAssertNotNil(viewController.yearSegmentedControl, "yearSegmentedControl should be connected")
        XCTAssertNotNil(viewController.numberOfPetsLabel, "numberOfPetsLabel should be connected")
        XCTAssertNotNil(viewController.morePetsSwitch, "morePetsSwitch should be connected")
        XCTAssertNotNil(viewController.morePetsStepper, "morePetsStepper should be connected")
    }

    // MARK: - Stepper Tests

    func testStepperDidChangeUpdatesLabel() {
        // Given
        let initialStepperValue = 3.0
        viewController.morePetsStepper.value = initialStepperValue

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "3", "numberOfPetsLabel should be updated with the stepper value")
    }

    func testStepperDidChangeWithZeroValue() {
        // Given
        viewController.morePetsStepper.value = 0.0

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "0", "numberOfPetsLabel should be updated with the stepper value")
    }

    func testStepperDidChangeWithNegativeValue() {
        // Given
        viewController.morePetsStepper.minimumValue = -5
        viewController.morePetsStepper.value = -2.0

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "-2", "numberOfPetsLabel should be updated with the stepper value")
    }

    // MARK: - Introduction Button Tests

    func testIntroduceSelfDidTappedPresentsAlert() {
        // Given
        let expectation = XCTestExpectation(description: "Alert is presented")
        viewController.firstNameTextField.text = "John"
        viewController.lastNameTextField.text = "Doe"
        viewController.schoolTextField.text = "CodePath"
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Freshman
        viewController.numberOfPetsLabel.text = "2"
        viewController.morePetsSwitch.isOn = true

        // Override present function to check if it's called
        viewController.presentationCompletion = {
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 2.0)
    }

    func testIntroduceSelfDidTappedAlertMessageContent() {
        // Given
        viewController.firstNameTextField.text = "Jane"
        viewController.lastNameTextField.text = "Smith"
        viewController.schoolTextField.text = "Stanford"
        viewController.yearSegmentedControl.selectedSegmentIndex = 1 // Sophomore
        viewController.numberOfPetsLabel.text = "1"
        viewController.morePetsSwitch.isOn = false

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        // Access the presented alert controller and verify its message
        XCTAssertNotNil(viewController.presentedViewController, "Alert controller should be presented")
        XCTAssertTrue(viewController.presentedViewController is UIAlertController, "Presented view controller should be a UIAlertController")

        let alertController = viewController.presentedViewController as! UIAlertController
        let expectedMessage = "My name is Jane Smith and I attend Stanford. I am currently in my Sophomore year and I own 1 dogs. It is false that I want more pets."
        XCTAssertEqual(alertController.message, expectedMessage, "Alert message should match the expected introduction")
    }

    func testIntroduceSelfDidTappedWithEmptyTextFields() {
        // Given
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.yearSegmentedControl.selectedSegmentIndex = 2 // Junior
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        // Access the presented alert controller and verify its message
        XCTAssertNotNil(viewController.presentedViewController, "Alert controller should be presented")
        XCTAssertTrue(viewController.presentedViewController is UIAlertController, "Presented view controller should be a UIAlertController")

        let alertController = viewController.presentedViewController as! UIAlertController
        let expectedMessage = "My name is  and I attend . I am currently in my Junior year and I own 0 dogs. It is false that I want more pets."
        XCTAssertEqual(alertController.message, expectedMessage, "Alert message should match the expected introduction")
    }

    func testIntroduceSelfDidTappedWithDifferentYear() {
        // Given
        viewController.firstNameTextField.text = "Test"
        viewController.lastNameTextField.text = "User"
        viewController.schoolTextField.text = "University"
        viewController.yearSegmentedControl.selectedSegmentIndex = 3 // Senior
        viewController.numberOfPetsLabel.text = "5"
        viewController.morePetsSwitch.isOn = true

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        // Access the presented alert controller and verify its message
        XCTAssertNotNil(viewController.presentedViewController, "Alert controller should be presented")
        XCTAssertTrue(viewController.presentedViewController is UIAlertController, "Presented view controller should be a UIAlertController")

        let alertController = viewController.presentedViewController as! UIAlertController
        let expectedMessage = "My name is Test User and I attend University. I am currently in my Senior year and I own 5 dogs. It is true that I want more pets."
        XCTAssertEqual(alertController.message, expectedMessage, "Alert message should match the expected introduction")
    }

}

// MARK: - Helper Extension for ViewController

extension ViewController {
    // Helper property to track when present is called
    var presentationCompletion: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.presentationCompletion) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.presentationCompletion, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // Override present to track when it's called
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        presentationCompletion?()
    }
}

private var AssociatedKeys: Void?
