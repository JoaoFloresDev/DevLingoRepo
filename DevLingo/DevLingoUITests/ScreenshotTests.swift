import XCTest

final class ScreenshotTests: XCTestCase {

    // MARK: - Properties

    private var app: XCUIApplication!

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-hasCompletedOnboarding", "true"]
        app.launch()
    }

    // MARK: - Screenshot Tests

    func testCaptureAllScreens() throws {
        sleep(4)

        // 1. Home screen
        takeScreenshot(named: "01_Home")

        // 2. Categories tab
        let tabBar = app.tabBars.firstMatch
        let categoriesTab = tabBar.buttons.element(boundBy: 1)
        if categoriesTab.waitForExistence(timeout: 5) {
            categoriesTab.tap()
            sleep(3)
            takeScreenshot(named: "02_Categories")
        }

        // 3. History tab
        let historyTab = tabBar.buttons.element(boundBy: 2)
        if historyTab.waitForExistence(timeout: 5) {
            historyTab.tap()
            sleep(3)
            takeScreenshot(named: "03_History")
        }

        // 4. Profile tab
        let profileTab = tabBar.buttons.element(boundBy: 3)
        if profileTab.waitForExistence(timeout: 5) {
            profileTab.tap()
            sleep(3)
            takeScreenshot(named: "04_Profile")
        }

        // 5. Go back to Categories and tap first category card
        categoriesTab.tap()
        sleep(2)

        // Try to find and tap a category card
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 3) {
            let firstButton = scrollView.buttons.firstMatch
            if firstButton.waitForExistence(timeout: 3) {
                firstButton.tap()
                sleep(3)
                takeScreenshot(named: "05_CategoryDetail")
            }
        }

        // 6. Onboarding
        app.terminate()

        let freshApp = XCUIApplication()
        freshApp.launchArguments += ["-hasCompletedOnboarding", "false"]
        freshApp.launch()
        sleep(4)
        takeScreenshot(named: "06_Onboarding")
    }

    // MARK: - Helpers

    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
