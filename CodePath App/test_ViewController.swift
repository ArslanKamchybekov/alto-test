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

    func testStepperDidChange_updatesNumberOfPetsLabel() {
        // Given
        let initialStepperValue = 3.0
        viewController.morePetsStepper.value = initialStepperValue

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "3", "numberOfPetsLabel should be updated with the stepper value")
    }

    func testStepperDidChange_zeroValue() {
        // Given
        viewController.morePetsStepper.value = 0.0

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "0", "numberOfPetsLabel should be updated with the stepper value")
    }

    func testStepperDidChange_negativeValue() {
        // Given
        viewController.morePetsStepper.minimumValue = -5.0
        viewController.morePetsStepper.value = -2.0

        // When
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "-2", "numberOfPetsLabel should be updated with the stepper value")
    }

    // MARK: - Introduction Button Tests

    func testIntroduceSelfDidTapped_presentsAlertController() {
        // Given
        let firstName = "John"
        let lastName = "Doe"
        let school = "University X"
        let numberOfPets = "2"
        let morePets = true
        let year = "Freshman"

        viewController.firstNameTextField.text = firstName
        viewController.lastNameTextField.text = lastName
        viewController.schoolTextField.text = school
        viewController.numberOfPetsLabel.text = numberOfPets
        viewController.morePetsSwitch.isOn = morePets
        viewController.yearSegmentedControl.selectedSegmentIndex = 0 // Assuming Freshman is at index 0
        
        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentationCompletion = { alertController in
            presentedAlertController = alertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        let expectedMessage = "My name is \(firstName) \(lastName) and I attend \(school). I am currently in my \(year) year and I own \(numberOfPets) dogs. It is \(morePets) that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should match the expected introduction")
        XCTAssertEqual(presentedAlertController?.actions.count, 1, "Alert controller should have one action")
        XCTAssertEqual(presentedAlertController?.actions.first?.title, "Nice to meet you!", "Alert controller action title should be correct")
    }

    func testIntroduceSelfDidTapped_emptyTextFields() {
        // Given
        viewController.firstNameTextField.text = ""
        viewController.lastNameTextField.text = ""
        viewController.schoolTextField.text = ""
        viewController.numberOfPetsLabel.text = "0"
        viewController.morePetsSwitch.isOn = false
        viewController.yearSegmentedControl.selectedSegmentIndex = 1 // Sophomore

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Mock the present function to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentationCompletion = { alertController in
            presentedAlertController = alertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        let expectedMessage = "My name is  and I attend . I am currently in my Sophomore year and I own 0 dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should match the expected introduction")
    }

    func testIntroduceSelfDidTapped_differentYearSelection() {
        // Given
        viewController.firstNameTextField.text = "Test"
        viewController.lastNameTextField.text = "User"
        viewController.schoolTextField.text = "Test School"
        viewController.numberOfPetsLabel.text = "1"
        viewController.morePetsSwitch.isOn = true

        // Test each year selection
        let years = ["Freshman", "Sophomore", "Junior", "Senior"]
        for i in 0..<years.count {
            viewController.yearSegmentedControl.selectedSegmentIndex = i
            
            // Create an expectation to wait for the alert to be presented
            let expectation = XCTestExpectation(description: "Alert controller presented for year \(years[i])")

            // Mock the present function to capture the alert controller
            var presentedAlertController: UIAlertController?
            viewController.presentationCompletion = { alertController in
                presentedAlertController = alertController
                expectation.fulfill()
            }

            // When
            viewController.introduceSelfDidTapped(UIButton())

            // Wait for the alert to be presented (with a timeout)
            wait(for: [expectation], timeout: 2.0)

            // Then
            XCTAssertNotNil(presentedAlertController, "Alert controller should be presented for year \(years[i])")
            let expectedMessage = "My name is Test User and I attend Test School. I am currently in my \(years[i]) year and I own 1 dogs. It is true that I want more pets."
            XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should match the expected introduction for year \(years[i])")
        }
    }

    // MARK: - Helper for mocking presentation

    // Helper property to inject a completion handler for presentation
    var presentationCompletion: ((UIAlertController) -> Void)?

    // Override the present function to capture the alert controller
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let alertController = viewControllerToPresent as? UIAlertController {
            presentationCompletion?(alertController)
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
