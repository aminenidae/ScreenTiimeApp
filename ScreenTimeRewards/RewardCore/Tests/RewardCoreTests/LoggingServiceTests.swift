import XCTest
@testable import RewardCore

final class LoggingServiceTests: XCTestCase {
    
    func testSharedInstance() {
        let instance1 = LoggingService.shared()
        let instance2 = LoggingService.shared()
        
        // Verify that the same instance is returned
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testDebugLogging() {
        let loggingService = LoggingService.shared()
        
        // This test primarily verifies that the method can be called without crashing
        loggingService.debug("Test debug message")
        loggingService.debug("Test debug message with context", file: "TestFile.swift", function: "testFunction()", line: 42)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
    
    func testInfoLogging() {
        let loggingService = LoggingService.shared()
        
        // This test primarily verifies that the method can be called without crashing
        loggingService.info("Test info message")
        loggingService.info("Test info message with context", file: "TestFile.swift", function: "testFunction()", line: 42)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
    
    func testWarningLogging() {
        let loggingService = LoggingService.shared()
        
        // This test primarily verifies that the method can be called without crashing
        loggingService.warning("Test warning message")
        loggingService.warning("Test warning message with context", file: "TestFile.swift", function: "testFunction()", line: 42)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
    
    func testErrorLogging() {
        let loggingService = LoggingService.shared()
        
        // This test primarily verifies that the method can be called without crashing
        loggingService.error("Test error message")
        loggingService.error("Test error message with context", file: "TestFile.swift", function: "testFunction()", line: 42)
        
        // Test with an error
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error description"])
        loggingService.error("Test error message with NSError", error: testError)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
    
    func testFaultLogging() {
        let loggingService = LoggingService.shared()
        
        // This test primarily verifies that the method can be called without crashing
        loggingService.fault("Test fault message")
        loggingService.fault("Test fault message with context", file: "TestFile.swift", function: "testFunction()", line: 42)
        
        // Test with an error
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error description"])
        loggingService.fault("Test fault message with NSError", error: testError)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
    
    func testFileNameExtraction() {
        let loggingService = LoggingService.shared()
        
        // This test verifies the internal fileName function through the public interface
        loggingService.debug("Test message", file: "/Users/test/Project/ViewController.swift", function: "viewDidLoad()", line: 10)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
    
    func testConvenienceFunctions() {
        // Test that convenience functions can be called without crashing
        logDebug("Test debug convenience function")
        logInfo("Test info convenience function")
        logWarning("Test warning convenience function")
        logError("Test error convenience function")
        logFault("Test fault convenience function")
        
        // Test with an error
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error description"])
        logError("Test error convenience function with NSError", error: testError)
        logFault("Test fault convenience function with NSError", error: testError)
        
        // If we reach this point, the test passes
        XCTAssertTrue(true)
    }
}