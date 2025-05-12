import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        // Instantiate the storyboard and ViewController
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

    func testStepperDidChangeUpdatesLabel() {
        // Given
        let initialStepperValue = 3.0
        viewController.morePetsStepper.value = initialStepperValue

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "3", "numberOfPetsLabel should be updated to stepper value")
    }

    func testStepperDidChangeWithZeroValue() {
        // Given
        viewController.morePetsStepper.value = 0.0

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "0", "numberOfPetsLabel should be updated to 0")
    }

    func testStepperDidChangeWithNegativeValue() {
        // Given
        viewController.morePetsStepper.minimumValue = -5.0
        viewController.morePetsStepper.value = -2.0

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "-2", "numberOfPetsLabel should be updated to negative stepper value")
    }

    // MARK: - Introduction Button Tests

    func testIntroduceSelfDidTappedPresentsAlert() {
        // Given
        let firstName = "John"
        let lastName = "Doe"
        let school = "CodePath University"
        let year = "Freshman"
        let numberOfPets = "2"
        let morePets = true

        viewController.firstNameTextField.text = firstName
        viewController.lastNameTextField.text = lastName
        viewController.schoolTextField.text = school
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Assuming Freshman is at index 0
        viewController.numberOfPetsLabel.text = numberOfPets
        viewController.morePetsSwitch.isOn = morePets

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Override present to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController?.present(viewController, animated: false, completion: nil)
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

        let expectedMessage = "My name is \(firstName) \(lastName) and I attend \(school). I am currently in my \(year) year and I own \(numberOfPets) dogs. It is \(morePets) that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct")

        // Check for the "Nice to meet you!" action
        XCTAssertNotNil(presentedAlertController?.actions.first(where: { $0.title == "Nice to meet you!" }), "Alert should have a 'Nice to meet you!' action")
    }

    func testIntroduceSelfDidTappedWithEmptyFields() {
        // Given (empty text fields)
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.yearSegmentedControl.selectedSegmentIndex = 0
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Override present to capture the alert controller
        var presentedAlertController: UIAlertController?
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

        let expectedMessage = "My name is   and I attend . I am currently in my Freshman year and I own 0 dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct with empty fields")
    }

    func testIntroduceSelfDidTappedWithDifferentYear() {
        // Given
        viewController.firstNameTextField.text = "Test"
        viewController.lastNameTextField.text = "User"
        viewController.schoolTextField.text = "Test School"
        viewController.yearSegmentedControl.selectedSegmentIndex = 2 // Assuming Junior is at index 2
        viewController.numberOfPetsLabel.text = "1"
        viewController.morePetsSwitch.isOn = true

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented")

        // Override present to capture the alert controller
        var presentedAlertController: UIAlertController?
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

        let expectedMessage = "My name is Test User and I attend Test School. I am currently in my Junior year and I own 1 dogs. It is true that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert message should be correct with Junior year")
    }

    // MARK: - Helper function to simulate button tap
    func simulateButtonTap(_ button: UIButton) {
        button.sendActions(for: .touchUpInside)
    }
}
