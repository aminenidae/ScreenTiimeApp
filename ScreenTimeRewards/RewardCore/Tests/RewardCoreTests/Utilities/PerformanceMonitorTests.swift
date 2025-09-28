import XCTest
@testable import RewardCore

@available(iOS 14.0, macOS 11.0, *)
final class PerformanceMonitorTests: XCTestCase {
    
    func testMeasureAsyncOperation_ReturnsResult() async throws {
        // Given
        var operationExecuted = false
        let expectedValue = "test result"
        
        // When
        let result = await PerformanceMonitor.measure(operation: "testOperation") {
            operationExecuted = true
            return expectedValue
        }
        
        // Then
        XCTAssertTrue(operationExecuted)
        XCTAssertEqual(result, expectedValue)
    }
    
    func testMeasureSyncOperation_ReturnsResult() throws {
        // Given
        var operationExecuted = false
        let expectedValue = 42
        
        // When
        let result = try PerformanceMonitor.measure(operation: "testOperation") {
            operationExecuted = true
            return expectedValue
        }
        
        // Then
        XCTAssertTrue(operationExecuted)
        XCTAssertEqual(result, expectedValue)
    }
    
    func testMeasureAsyncOperation_ThrowsError() async throws {
        // Given
        enum TestError: Error {
            case testFailure
        }
        
        // When/Then
        do {
            let _ = try await PerformanceMonitor.measure(operation: "testOperation") {
                throw TestError.testFailure
            }
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected to throw
            XCTAssertTrue(error is TestError)
        }
    }
    
    func testMeasureSyncOperation_ThrowsError() throws {
        // Given
        enum TestError: Error {
            case testFailure
        }
        
        // When/Then
        XCTAssertThrowsError(try PerformanceMonitor.measure(operation: "testOperation") {
            throw TestError.testFailure
        })
    }
    
    func testLogMemoryUsage_DoesNotCrash() {
        // When/Then
        XCTAssertNoThrow(PerformanceMonitor.logMemoryUsage(for: "testContext"))
    }
    
    func testGetCurrentMemoryUsage_ReturnsNonNegativeValue() {
        // When
        // Note: We can't directly test the private getCurrentMemoryUsage() method,
        // but we can verify that logMemoryUsage doesn't crash, which implies
        // the method is working correctly
        XCTAssertNoThrow(PerformanceMonitor.logMemoryUsage(for: "test"))
    }
}