# Error Handling Strategy

## Error Types

```swift
enum AppError: LocalizedError {
    case networkUnavailable
    case cloudKitNotAvailable
    case insufficientPoints
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection."
        case .insufficientPoints:
            return "Not enough points for this reward."
        // ...
        }
    }
}
```

## Error Handling Pattern

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var showError = false

    func loadData() async {
        do {
            let data = try await repository.fetchData()
        } catch let error as AppError {
            errorMessage = error.errorDescription
            showError = true
        }
    }
}
```

---
