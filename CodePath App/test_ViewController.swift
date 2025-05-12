import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        // Instantiate the ViewController from the Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        
        // Ensure the view is loaded to trigger IBOutlet connections
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

    // MARK: - Stepper Tests

    func testStepperDidChange_updatesLabelText() {
        // Given
        let initialStepperValue = 3.0
        viewController.morePetsStepper.value = initialStepperValue

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "3", "numberOfPetsLabel should be updated with the stepper's value")

        // Given
        let newStepperValue = 7.0
        viewController.morePetsStepper.value = newStepperValue

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "7", "numberOfPetsLabel should be updated with the stepper's value")
    }

    // MARK: - Introduction Button Tests

    func testIntroduceSelfDidTapped_presentsAlertController() {
        // Given
        let firstName = "John"
        let lastName = "Doe"
        let school = "CodePath University"
        let year = "Freshman"
        let numberOfPets = "2"
        let wantsMorePets = true

        viewController.firstNameTextField.text = firstName
        viewController.lastNameTextField.text = lastName
        viewController.schoolTextField.text = school
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Assuming Freshman is at index 0
        viewController.numberOfPetsLabel.text = numberOfPets
        viewController.morePetsSwitch.isOn = wantsMorePets

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = MockViewController() // Need a presenting view controller
        viewController.present = { (vc, animated, completion) in
            presentedAlertController = vc as? UIAlertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "An alert controller should be presented")
        XCTAssertEqual(presentedAlertController?.title, "My Introduction", "Alert controller title should be correct")

        let expectedMessage = "My name is \(firstName) \(lastName) and I attend \(school). I am currently in my \(year) year and I own \(numberOfPets) dogs. It is \(wantsMorePets) that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should be correct")

        XCTAssertEqual(presentedAlertController?.actions.count, 1, "Alert controller should have one action")
        XCTAssertEqual(presentedAlertController?.actions.first?.title, "Nice to meet you!", "Alert controller action title should be correct")
    }

    func testIntroduceSelfDidTapped_emptyTextFields() {
        // Given
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.yearSegmentedControl.selectedSegmentIndex = 0
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = MockViewController() // Need a presenting view controller
        viewController.present = { (vc, animated, completion) in
            presentedAlertController = vc as? UIAlertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "An alert controller should be presented")

        let expectedMessage = "My name is  and I attend . I am currently in my Freshman year and I own 0 dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should be correct")
    }

    // MARK: - Helper Mock Class

    class MockViewController: UIViewController {
        var presentedViewController: UIViewController?
        var isAnimated: Bool?
        var completionBlock: (() -> Void)?

        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presentedViewController = viewControllerToPresent
            isAnimated = flag
            completionBlock = completion
        }
    }
}
