import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        // Instantiate the view controller from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        
        // Ensure the view is loaded before running tests
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
        viewController.morePetsStepper.value = 5
        
        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "5", "numberOfPetsLabel should update with stepper value")

        // Test with a different value
        viewController.morePetsStepper.value = 0
        viewController.stepperDidChange(viewController.morePetsStepper)
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "0", "numberOfPetsLabel should update with stepper value")

        // Test with a negative value (stepper should prevent this, but test for robustness)
        viewController.morePetsStepper.value = -2
        viewController.stepperDidChange(viewController.morePetsStepper)
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "0", "numberOfPetsLabel should update with stepper value") // Assuming stepper min is 0
    }

    func testIntroduceSelfDidTapped() {
        // Given
        viewController.firstNameTextField.text = "John"
        viewController.lastNameTextField.text = "Doe"
        viewController.schoolTextField.text = "CodePath"
        viewController.yearSegmentedControl.selectedSegmentIndex = 1 // Assuming 1 is Sophomore
        viewController.numberOfPetsLabel.text = "2"
        viewController.morePetsSwitch.isOn = true

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert presented")

        // Override the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = UIViewController() // Mock presenting view controller
        viewController.present = { (alertController, animated, completion) in
            presentedAlertController = alertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented
        wait(for: [expectation], timeout: 5.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        XCTAssertEqual(presentedAlertController?.title, "My Introduction", "Alert title should be correct")

        // Verify the message
        let expectedMessage = "My name is John Doe and I attend CodePath. I am currently in my Sophomore year and I own 2 dogs. It is true that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct")

        // Verify the action
        XCTAssertEqual(presentedAlertController?.actions.count, 1, "Alert should have one action")
        XCTAssertEqual(presentedAlertController?.actions.first?.title, "Nice to meet you!", "Action title should be correct")
        XCTAssertEqual(presentedAlertController?.preferredStyle, .alert, "Alert style should be correct")

        // Test with different values
        viewController.firstNameTextField.text = "Jane"
        viewController.lastNameTextField.text = "Smith"
        viewController.schoolTextField.text = "AnotherSchool"
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Assuming 0 is Freshman
        viewController.numberOfPetsLabel.text = "5"
        viewController.morePetsSwitch.isOn = false

        let expectation2 = XCTestExpectation(description: "Alert presented 2")
        var presentedAlertController2: UIAlertController?
        viewController.present = { (alertController, animated, completion) in
            presentedAlertController2 = alertController
            expectation2.fulfill()
        }

        viewController.introduceSelfDidTapped(UIButton())
        wait(for: [expectation2], timeout: 5.0)

        XCTAssertNotNil(presentedAlertController2, "Alert controller should be presented")
        let expectedMessage2 = "My name is Jane Smith and I attend AnotherSchool. I am currently in my Freshman year and I own 5 dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController2?.message, expectedMessage2, "Alert message should be correct")

        // Test with empty text fields
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.numberOfPetsLabel.text = ""

        let expectation3 = XCTestExpectation(description: "Alert presented 3")
        var presentedAlertController3: UIAlertController?
        viewController.present = { (alertController, animated, completion) in
            presentedAlertController3 = alertController
            expectation3.fulfill()
        }

        viewController.introduceSelfDidTapped(UIButton())
        wait(for: [expectation3], timeout: 5.0)

        XCTAssertNotNil(presentedAlertController3, "Alert controller should be presented")
        let expectedMessage3 = "My name is   and I attend . I am currently in my Freshman year and I own  dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController3?.message, expectedMessage3, "Alert message should be correct")
    }

    // MARK: - View Lifecycle Tests

    func testViewDidLoad() {
        // This test primarily checks that viewDidLoad executes without crashing.
        // More specific tests can be added if viewDidLoad performs significant setup.
        XCTAssertNotNil(viewController.view, "View should be loaded")
    }
}
