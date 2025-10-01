# External APIs

**Assessment:** This application is a **self-contained iOS app** with no external third-party API dependencies.

**No External APIs Required:**
- Authentication: iCloud + Family Sharing
- Data Storage: CloudKit
- Screen Time: Family Controls Framework
- Push Notifications: APNs via CloudKit
- Analytics: MetricKit + OSLog

**Apple Services (Not External):**

| Service | Purpose | Access Method |
|---------|---------|---------------|
| iCloud Authentication | User sign-in | `CKContainer.default().accountStatus()` |
| CloudKit | Data storage and sync | Native CloudKit SDK |
| APNs | Push notifications | CloudKit subscriptions |
| Family Sharing | Family discovery | FamilyActivityPicker |
| StoreKit 2 | In-app purchases | `Product.products(for:)`, `Transaction.currentEntitlements` |
| CloudKit Functions | Receipt validation | Custom CloudKit function (server-side) |
| App Store Server API | Transaction info | StoreKit 2 Transaction verification |

---
