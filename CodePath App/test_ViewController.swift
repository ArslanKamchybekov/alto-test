import XCTest
@testable import CodePath_App

class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        // Instantiate the storyboard and ViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        
        // Load the view to trigger IBOutlet connections
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
        let initialStepperValue = 0.0
        viewController.morePetsStepper.value = initialStepperValue
        viewController.stepperDidChange(viewController.morePetsStepper)

        // When
        let newStepperValue = 3.0
        viewController.morePetsStepper.value = newStepperValue
        viewController.stepperDidChange(viewController.morePetsStepper)

        // Then
        XCTAssertEqual(viewController.numberOfPetsLabel.text, "3", "numberOfPetsLabel should be updated to the stepper's value")
    }

    // MARK: - Introduction Button Tests

    func testIntroduceSelfDidTapped_presentsAlertController() {
        // Given
        let firstName = "John"
        let lastName = "Doe"
        let school = "CodePath University"
        let year = "4th"
        let numberOfPets = "2"
        let morePets = true

        viewController.firstNameTextField.text = firstName
        viewController.lastNameTextField.text = lastName
        viewController.schoolTextField.text = school
        viewController.yearSegmentedControl.selectedSegmentIndex = 3 // Assuming 4th year is at index 3
        viewController.numberOfPetsLabel.text = numberOfPets
        viewController.morePetsSwitch.isOn = morePets

        // Create an expectation to wait for the alert to be presented
        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Override present to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = UIViewController() // Need a presenting view controller
        viewController.present = { (alertController, animated, completion) in
            presentedAlertController = alertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")
        XCTAssertEqual(presentedAlertController?.title, "My Introduction", "Alert controller title should be correct")

        let expectedMessage = "My name is \(firstName) \(lastName) and I attend \(school). I am currently in my \(year) year and I own \(numberOfPets) dogs. It is \(morePets) that I want more pets."
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

        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Override present to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = UIViewController() // Need a presenting view controller
        viewController.present = { (alertController, animated, completion) in
            presentedAlertController = alertController
            expectation.fulfill()
        }

        // When
        viewController.introduceSelfDidTapped(UIButton())

        // Wait for the alert to be presented (with a timeout)
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(presentedAlertController, "Alert controller should be presented")

        let expectedMessage = "My name is  and I attend . I am currently in my 1st year and I own 0 dogs. It is false that I want more pets."
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should be correct even with empty text fields")
    }

    func testIntroduceSelfDidTapped_specialCharacters() {
        // Given
        let firstName = "!@#$%^"
        let lastName = "&*()"
        let school = "_+-=[]"
        let year = "2nd"
        let numberOfPets = "10"
        let morePets = true

        viewController.firstNameTextField.text = firstName
        viewController.lastNameTextField.text = lastName
        viewController.schoolTextField.text = school
        viewController.yearSegmentedControl.selectedSegmentIndex = 1 // Assuming 2nd year is at index 1
        viewController.numberOfPetsLabel.text = numberOfPets
        viewController.morePetsSwitch.isOn = morePets

        let expectation = XCTestExpectation(description: "Alert controller presented")

        // Override present to capture the alert controller
        var presentedAlertController: UIAlertController?
        viewController.presentingViewController = UIViewController() // Need a presenting view controller
        viewController.present = { (alertController, animated, completion) in
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
        XCTAssertEqual(presentedAlertController?.message, expectedMessage, "Alert controller message should be correct even with special characters")
    }
}

// Helper extension to override present for testing
extension ViewController {
    typealias PresentViewControllerClosure = (UIAlertController, Bool, (() -> Void)?) -> Void
    
    var present: PresentViewControllerClosure? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.presentKey) as? PresentViewControllerClosure
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.presentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private struct AssociatedKeys {
        static var presentKey: UInt8 = 0
    }
}
