# Monitoring and Observability

## Monitoring Stack

- **MetricKit:** Battery, crashes, performance
- **OSLog:** Structured logging
- **Xcode Organizer:** Crash reports, energy logs

## Key Metrics

- Launch time (cold/warm)
- Memory footprint
- Battery drain
- Crash-free sessions %
- Points earned per child per day
- Trial-to-paid conversion rate
- Monthly churn rate
- Payment failure rate
- Subscription validation latency

```swift
import OSLog

let logger = Logger(subsystem: "com.yourcompany.screentimerewards", category: "sync")

func syncChildProfile() async {
    logger.info("Starting sync", metadata: ["childID": "\(childID, privacy: .private)"])
}
```

---
