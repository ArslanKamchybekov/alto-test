import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()
        // Instantiate the ViewController from the Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        
        // Ensure the view is loaded before accessing outlets
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    // MARK: - Outlet Tests

    func testOutletsAreConnected() {
        XCTAssertNotNil(viewController.firstNameTextField, "firstNameTextField should be connected")
        XCTAssertNotNil(viewController.lastNameTextField, "lastNameTextField should be connected")
        XCTAssertNotNil(viewController.schoolTextField, "schoolTextField should be connected")
        XCTAssertNotNil(viewController.yearSegmentedControl, "yearSegmentedControl should be connected")
        XCTAssertNotNil(viewController.numberOfPetsLabel, "numberOfPetsLabel should be connected")
        XCTAssertNotNil(viewController.morePetsSwitch, "morePetsSwitch should be connected")
        XCTAssertNotNil(viewController.morePetsStepper, "morePetsStepper should be connected")
    }

    // MARK: - Action Tests

    func testStepperDidChange() {
        // Given
        let initialValue = 3.0
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
        viewController.yearSegmentedControl.selectedSegmentIndex = 1 // Sophomore
        viewController.numberOfPetsLabel.text = "2"
        viewController.morePetsSwitch.isOn = true

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = MockViewController() // Need a presenting view controller for present to work
        viewController.present = { (vc, animated, completion) in
            presentedAlertController = vc as? UIAlertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 5.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        XCTAssertEqual(presentedAlertController?.title, "My Introduction", "Alert title should be correct")

        let expectedMessage = "My name is John Doe and I attend CodePath University. I am currently in my Sophomore year and I own 2 dogs. It is true that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct")

        XCTAssertEqual(presentedAlertController?.actions.count, 1, "Alert should have one action")
        XCTAssertEqual(presentedAlertController?.actions.first?.title, "Nice to meet you!", "Alert action title should be correct")
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
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = MockViewController() // Need a presenting view controller for present to work
        viewController.present = { (vc, animated, completion) in
            presentedAlertController = vc as? UIAlertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 5.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        XCTAssertEqual(presentedAlertController?.title, "My Introduction", "Alert title should be correct")

        let expectedMessage = "My name is  and I attend . I am currently in my Freshman year and I own 0 dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct")

        XCTAssertEqual(presentedAlertController?.actions.count, 1, "Alert should have one action")
        XCTAssertEqual(presentedAlertController?.actions.first?.title, "Nice to meet you!", "Alert action title should be correct")
    }

    func testIntroduceSelfDidTapped_withNilPetLabel() {
        // Given
        viewController.firstNameTextField.text = "Test"
        viewController.lastNameTextField.text = "User"
        viewController.schoolTextField.text = "Test School"
        viewController.yearSegmentedControl.selectedSegmentIndex = 2
        viewController.numberOfPetsLabel.text = nil
        viewController.morePetsSwitch.isOn = true

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = MockViewController() // Need a presenting view controller for present to work
        viewController.present = { (vc, animated, completion) in
            presentedAlertController = vc as? UIAlertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 5.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        XCTAssertEqual(presentedAlertController?.title, "My Introduction", "Alert title should be correct")

        let expectedMessage = "My name is Test User and I attend Test School. I am currently in my Junior year and I own  dogs. It is true that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct")

        XCTAssertEqual(presentedAlertController?.actions.count, 1, "Alert should have one action")
        XCTAssertEqual(presentedAlertController?.actions.first?.title, "Nice to meet you!", "Alert action title should be correct")
    }

    // MARK: - Helper Mock

    class MockViewController: UIViewController {}
}
