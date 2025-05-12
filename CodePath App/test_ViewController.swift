import XCTest
@testable import CodePath_App // Replace with your actual module name

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        // Instantiate the ViewController from the Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        
        // Load the view hierarchy to ensure outlets are connected
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

    // MARK: - Stepper Tests

    func testStepperDidChangeUpdatesLabel() {
        // Given
        let initialValue = 0.0
        viewController.morePetsStepper.value = initialValue
        viewController.stepperDidChange(viewController.morePetsStepper)

        // When
        let newValue = 5.0
        viewController.morePetsStepper.value = newValue
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "5", "numberOfPetsLabel should be updated to the stepper's value")
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

        // Override the present function to check if the alert is presented
        viewController.presentingViewController = UIViewController() // Required for present to work in tests
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be 'My Introduction'")
            let expectedMessage = "My name is \(firstName) \(lastName) and I attend \(school). I am currently in my \(year) year and I own \(numberOfPets) dogs. It is \(morePets) that I want more pets."
            XCTAssertEqual(alertController.message, expectedMessage, "Alert message should match the expected introduction")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Action title should be 'Nice to meet you!'")
            expectation.fulfill()
            completion?() // Call the completion handler
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 5.0)
    }

    func testIntroduceSelfDidTappedWithEmptyFields() {
        // Given (Empty fields)
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.yearSegmentedControl.selectedSegmentIndex = 0
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert is presented with empty fields")

        // Override the present function to check if the alert is presented
        viewController.presentingViewController = UIViewController() // Required for present to work in tests
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be 'My Introduction'")
            let expectedMessage = "My name is  and I attend . I am currently in my Freshman year and I own 0 dogs. It is false that I want more pets."
            XCTAssertEqual(alertController.message, expectedMessage, "Alert message should match the expected introduction with empty fields")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Action title should be 'Nice to meet you!'")
            expectation.fulfill()
            completion?() // Call the completion handler
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 5.0)
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
        let expectation = XCTestExpectation(description: "Alert is presented with different year")

        // Override the present function to check if the alert is presented
        viewController.presentingViewController = UIViewController() // Required for present to work in tests
        viewController.present = { (alertController, animated, completion) in
            XCTAssertEqual(alertController.title, "My Introduction", "Alert title should be 'My Introduction'")
            let expectedMessage = "My name is Test User and I attend Test School. I am currently in my Junior year and I own 1 dogs. It is true that I want more pets."
            XCTAssertEqual(alertController.message, expectedMessage, "Alert message should match the expected introduction with different year")
            XCTAssertEqual(alertController.actions.count, 1, "Alert should have one action")
            XCTAssertEqual(alertController.actions.first?.title, "Nice to meet you!", "Action title should be 'Nice to meet you!'")
            expectation.fulfill()
            completion?() // Call the completion handler
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Then
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Helper Functions

    // Helper function to simulate tapping a segmented control segment
    func tapSegmentedControlSegment(at index: Int) {
        viewController.yearSegmentedControl.selectedSegmentIndex = index
        viewController.yearSegmentedControl.sendActions(for: .valueChanged)
    }
}
