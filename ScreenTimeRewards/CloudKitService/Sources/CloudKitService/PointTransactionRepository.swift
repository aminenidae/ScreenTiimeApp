import Foundation
import CloudKit
import SharedModels
import OSLog

@available(iOS 15.0, macOS 12.0, *)
public class PointTransactionRepository: SharedModels.PointTransactionRepository {
    private let database: CKDatabase
    private let logger = Logger(subsystem: "com.screentime.rewards", category: "point-transactions")

    public init(database: CKDatabase = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }
    
    /// Creates a new point transaction in CloudKit
    public func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction {
        do {
            logger.info("Creating point transaction for child: \(transaction.childProfileID)")

            let record = try createCKRecord(from: transaction)
            let savedRecord = try await database.save(record)
            return try createPointTransaction(from: savedRecord)
        } catch let ckError as CKError {
            logger.error("CloudKit error creating transaction: \(ckError.localizedDescription)")
            throw mapCloudKitError(ckError)
        } catch {
            logger.error("Error creating transaction: \(error.localizedDescription)")
            throw AppError.systemError(error.localizedDescription)
        }
    }
    
    /// Fetches a specific point transaction by ID
    public func fetchTransaction(id: String) async throws -> PointTransaction? {
        do {
            logger.info("Fetching point transaction with id: \(id)")

            let recordID = CKRecord.ID(recordName: id)
            let record = try await database.record(for: recordID)
            return try createPointTransaction(from: record)
        } catch let ckError as CKError {
            if ckError.code == .unknownItem {
                return nil
            }
            logger.error("CloudKit error fetching transaction: \(ckError.localizedDescription)")
            throw mapCloudKitError(ckError)
        } catch {
            logger.error("Error fetching transaction: \(error.localizedDescription)")
            throw AppError.systemError(error.localizedDescription)
        }
    }

    /// Fetches point transactions for a child profile with an optional limit
    public func fetchTransactions(for childID: String, limit: Int?) async throws -> [PointTransaction] {
        do {
            logger.info("Fetching point transactions for child: \(childID)")

            let predicate = NSPredicate(format: "childProfileID == %@", childID)
            let query = CKQuery(recordType: "PointTransaction", predicate: predicate)

            let (records, _) = try await database.records(matching: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: limit ?? CKQueryOperation.maximumResults)

            return try records.compactMap { _, result in
                switch result {
                case .success(let record):
                    return try createPointTransaction(from: record)
                case .failure(let error):
                    logger.warning("Failed to process record: \(error.localizedDescription)")
                    return nil
                }
            }
        } catch let ckError as CKError {
            logger.error("CloudKit error fetching transactions: \(ckError.localizedDescription)")
            throw mapCloudKitError(ckError)
        } catch {
            logger.error("Error fetching transactions: \(error.localizedDescription)")
            throw AppError.systemError(error.localizedDescription)
        }
    }

    /// Fetches point transactions for a child profile within a date range
    public func fetchTransactions(for childID: String, dateRange: DateRange?) async throws -> [PointTransaction] {
        // Simplified implementation without date range for now
        return try await fetchTransactions(for: childID, limit: nil)
    }

    /// Deletes a point transaction from CloudKit
    public func deleteTransaction(id: String) async throws {
        do {
            logger.info("Deleting point transaction with id: \(id)")

            let recordID = CKRecord.ID(recordName: id)
            let _ = try await database.deleteRecord(withID: recordID)
        } catch let ckError as CKError {
            logger.error("CloudKit error deleting transaction: \(ckError.localizedDescription)")
            throw mapCloudKitError(ckError)
        } catch {
            logger.error("Error deleting transaction: \(error.localizedDescription)")
            throw AppError.systemError(error.localizedDescription)
        }
    }

    /// Saves a point transaction (alternative method name for consistency)
    public func save(transaction: PointTransaction) async throws {
        let _ = try await createTransaction(transaction)
    }

    // MARK: - Helper Methods

    /// Creates a CloudKit record from a PointTransaction model
    private func createCKRecord(from transaction: PointTransaction) throws -> CKRecord {
        let record = CKRecord(recordType: "PointTransaction")
        record["childProfileID"] = transaction.childProfileID
        record["points"] = transaction.points
        record["reason"] = transaction.reason
        record["timestamp"] = transaction.timestamp

        return record
    }

    /// Creates a PointTransaction model from a CloudKit record
    private func createPointTransaction(from record: CKRecord) throws -> PointTransaction {
        guard let childProfileID = record["childProfileID"] as? String,
              let points = record["points"] as? Int,
              let reason = record["reason"] as? String,
              let timestamp = record["timestamp"] as? Date else {
            throw AppError.invalidData("Invalid PointTransaction record format")
        }

        return PointTransaction(
            id: record.recordID.recordName,
            childProfileID: childProfileID,
            points: points,
            reason: reason,
            timestamp: timestamp
        )
    }

    /// Map CloudKit errors to AppError types
    private func mapCloudKitError(_ ckError: CKError) -> AppError {
        switch ckError.code {
        case .networkUnavailable, .networkFailure:
            return .networkUnavailable
        case .requestRateLimited:
            return .networkTimeout
        case .notAuthenticated:
            return .authenticationFailed
        case .permissionFailure:
            return .unauthorized
        case .accountTemporarilyUnavailable:
            return .cloudKitNotAvailable
        case .unknownItem:
            return .cloudKitRecordNotFound
        case .serverRecordChanged:
            return .cloudKitSaveError("Record was modified by another device")
        case .zoneBusy:
            return .cloudKitZoneError("Zone is busy, try again later")
        case .zoneNotFound:
            return .cloudKitZoneError("Zone not found")
        case .quotaExceeded:
            return .cloudKitSaveError("iCloud storage quota exceeded")
        case .operationCancelled:
            return .operationNotAllowed("Operation was cancelled")
        default:
            return .cloudKitSaveError("CloudKit operation failed: \(ckError.localizedDescription)")
        }
    }
}