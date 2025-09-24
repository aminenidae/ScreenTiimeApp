# Developer Handoff Document

**Project:** Reward-Based Screen Time Management App
**Status:** ✅ APPROVED FOR DEVELOPMENT
**Start Date:** Ready to begin
**Product Owner:** Sarah

---

## Quick Start

### What Changed
1. ✅ **Multi-parent features deferred to v1.1** (3 weeks saved)
2. ✅ **Epic 1-3 stories corrected** (infrastructure setup fixed)
3. ✅ **iOS version updated** to 15.0+ (Family Controls requirement)
4. ✅ **Epic 6 added** for v1.1 (multi-parent collaboration)

### What to Build First

**Week 1-2: Epic 1 - Foundation**
```
Story 1.1: SPM package structure + Xcode project
Story 1.2: Family Controls integration
Story 1.3: CloudKit schema + repository protocols
Story 1.4: iCloud authentication (single-parent)
```

**Start Here:** Story 1.1 - Project scaffolding

---

## Critical Fixes Applied

### Fix #1: Package Structure (Story 1.1)
**Added to acceptance criteria:**
- Create `Packages/SharedModels/` - Data models and enums
- Create `Packages/DesignSystem/` - UI components
- Create `Packages/RewardCore/` - Business logic
- Create `Packages/CloudKitService/` - CloudKit wrapper
- Create `Packages/FamilyControlsKit/` - Family Controls wrapper

**Action:** Create these packages BEFORE implementing features

---

### Fix #2: CloudKit Schema (Story 1.3)
**Added to acceptance criteria:**
- Deploy CloudKit schema with 7 record types
- Create custom zones (per-child private zones)
- Define repository protocols (Family, Child, etc.)
- Implement CoreData local cache
- Create mock repositories for testing

**Action:** Deploy CloudKit schema in Story 1.3, BEFORE Story 1.4

---

### Fix #3: Repository Protocols (Story 1.3)
**Added to acceptance criteria:**
- `FamilyRepository` protocol
- `ChildProfileRepository` protocol
- `AppCategorizationRepository` protocol
- `UsageSessionRepository` protocol
- `PointTransactionRepository` protocol

**Action:** Define protocols in Story 1.3, implement in subsequent stories

---

### Fix #4: Multi-Parent Deferred (v1.1)
**Removed from v1.0:**
- Multi-parent authentication (Story 1.4)
- Co-parent dashboard visibility (Story 3.1)
- Entire Story 3.5 (invite/manage parents)

**Prepare for v1.1:**
- Include `Family.sharedWithUserIDs` field (empty in v1.0)
- Include `metadata.modifiedBy` in all models
- Build single-parent UI that can expand later

**Action:** Build single-parent functionality, keep data model multi-parent ready

---

## Technology Stack Reference

| Category | Technology | Version | Notes |
|----------|-----------|---------|-------|
| **Language** | Swift | 5.9+ | Native iOS |
| **UI Framework** | SwiftUI | iOS 15.0+ | Declarative UI |
| **Backend** | CloudKit | iOS 15.0+ | Serverless |
| **Screen Time** | Family Controls | iOS 15.0+ | NOT Screen Time API |
| **Local Cache** | CoreData | iOS 15.0+ | Offline support |
| **State Management** | Combine | iOS 15.0+ | Reactive streams |
| **Package Manager** | SPM | Swift 5.9+ | Local packages |
| **Testing** | XCTest | Xcode 15.0+ | Unit + Integration |

**⚠️ Important:** Use Family Controls framework, NOT deprecated Screen Time API

---

## Development Sequence

### Epic 1: Foundation (2.5 weeks)
```
✅ Story 1.1: Project + Packages (3 days)
✅ Story 1.2: Family Controls integration (4 days)
✅ Story 1.3: CloudKit schema + repositories (5 days)
✅ Story 1.4: iCloud auth (single-parent) (3 days)
```

### Epic 2: Core Reward System (3 weeks)
```
✅ Story 2.1: App categorization (4 days)
✅ Story 2.2: Point tracking engine (5 days)
✅ Story 2.3: Reward conversion (4 days)
✅ Story 2.4: Parental controls (2 days)
```

### Epic 3: User Experience (2.5 weeks)
```
✅ Story 3.1: Parent dashboard (single-parent) (4 days)
✅ Story 3.2: Child dashboard (4 days)
✅ Story 3.3: App categorization screen (3 days)
✅ Story 3.4: Settings screen (4 days)
❌ Story 3.5: DEFERRED to v1.1
```

### Epic 4: Reporting (2 weeks)
### Epic 5: Validation & Testing (2 weeks)

**Total v1.0 MVP:** 12 weeks

---

## Key Architecture Decisions

### CloudKit Zone Strategy
```
- Default Zone: Family, FamilySettings
- Custom Zone per Child: "child-{UUID}"
  - ChildProfile
  - AppCategorization
  - UsageSession
  - PointTransaction
  - RewardRedemption
```

### Repository Pattern
```swift
// Define protocols in Story 1.3
protocol FamilyRepository {
    func createFamily(_ family: Family) -> AnyPublisher<Family, Error>
    func fetchFamily(id: UUID) -> AnyPublisher<Family, Error>
    // ...
}

// Implement in CloudKitService
class CloudKitFamilyRepository: FamilyRepository {
    // Implementation
}

// Use in ViewModels
class DashboardViewModel {
    private let familyRepo: FamilyRepository
}
```

### Data Model Preparation for v1.1
```swift
struct Family {
    let id: UUID
    let name: String
    let ownerUserID: String
    var sharedWithUserIDs: [String] = [] // Empty in v1.0, populated in v1.1
    // ...
}

// All models include:
struct Metadata {
    let modifiedBy: String // Track which parent made changes
    let modifiedAt: Date
}
```

---

## Testing Requirements

### Story 1.1
- ✅ Project compiles
- ✅ All packages load correctly
- ✅ Navigation structure works

### Story 1.2
- ⚠️ **Requires physical device** (Family Controls not in Simulator)
- ✅ Authorization request appears
- ✅ Parent/child role detection works

### Story 1.3
- ✅ CloudKit schema deployed successfully
- ✅ Repository protocols compile
- ✅ Mock repositories pass unit tests
- ✅ CoreData cache saves/retrieves

### Story 1.4
- ✅ iCloud account status detected
- ✅ Family creation works
- ✅ Single parent can authenticate
- ✅ Data isolation verified

---

## Common Pitfalls to Avoid

### ❌ Don't Do This
1. ❌ Start coding before creating packages (Story 1.1)
2. ❌ Use Screen Time API instead of Family Controls
3. ❌ Deploy CloudKit schema manually (use Xcode)
4. ❌ Implement features before repository protocols exist
5. ❌ Add multi-parent features to v1.0 (deferred to v1.1)
6. ❌ Test Family Controls on Simulator (won't work)

### ✅ Do This
1. ✅ Create all SPM packages in Story 1.1
2. ✅ Use Family Controls framework (iOS 15.0+)
3. ✅ Deploy CloudKit schema via Xcode in Story 1.3
4. ✅ Define repository protocols before implementations
5. ✅ Build single-parent UI, prepare data model for v1.1
6. ✅ Test Family Controls on physical device

---

## v1.1 Preparation

### What to Include Now (for v1.1 compatibility)
```swift
// Family model
struct Family {
    var sharedWithUserIDs: [String] = [] // ← Include this
}

// All models
struct AppCategorization {
    let createdBy: String // ← Include this
    let modifiedBy: String // ← Include this
}
```

### What NOT to Implement Now
- ❌ Parent invitation flow
- ❌ Real-time sync infrastructure
- ❌ Activity log UI
- ❌ Conflict resolution
- ❌ Multi-parent permissions

**These are Epic 6 (v1.1), starting Week 14**

---

## Resources

### Documentation
- **PRD:** `/docs/prd.md` (updated with Epic 6)
- **Architecture:** `/docs/architecture.md`
- **PO Validation:** `/docs/po-validation-summary.md` (this summary)
- **CLAUDE.md:** Project instructions for Claude Code

### Key Files to Reference
```
.bmad-core/core-config.yaml          # Project configuration
docs/prd.md                          # Product requirements (v1.0 + v1.1)
docs/architecture.md                 # Technical architecture
docs/po-validation-summary.md        # Validation results
```

### Slack/Communication
- Tag Product Owner (Sarah) for story clarifications
- Report blocking issues immediately
- Daily standup: Progress on current story
- Weekly demo: Completed epic functionality

---

## Definition of Done (Story-Level)

**Every story must have:**
1. ✅ All acceptance criteria met
2. ✅ Unit tests written and passing
3. ✅ Code follows architecture patterns
4. ✅ Repository protocols used (not direct CloudKit)
5. ✅ Tested on physical device (if Family Controls involved)
6. ✅ No compiler warnings
7. ✅ README updated (if setup changes)
8. ✅ Story marked complete in tracking system

**Epic-level DoD:**
1. ✅ All stories complete
2. ✅ Integration tests passing
3. ✅ Epic demo to Product Owner
4. ✅ Regression tests pass (if Epic 2+)

---

## FAQ

**Q: Why iOS 15.0 minimum instead of 14.0?**
A: Family Controls framework requires iOS 15.0+. Covers 95%+ of market.

**Q: Why defer multi-parent features?**
A: Reduces MVP complexity 35%, saves 3 weeks, eliminates high-risk CloudKit sync bugs. v1.1 delivers full feature set.

**Q: What's the difference between Family Controls and Screen Time API?**
A: Family Controls is modern (iOS 15+), robust, and recommended. Screen Time API is deprecated and less reliable.

**Q: Can I use Firebase instead of CloudKit?**
A: No. Architecture specifies CloudKit for serverless, iCloud integration, and zero backend maintenance.

**Q: Should I test on Simulator or device?**
A: Physical device required for Family Controls. Simulator OK for UI-only work.

**Q: What if I find a blocking issue?**
A: Halt development, document issue, tag Product Owner (Sarah) immediately.

---

## Success Criteria (v1.0 MVP)

**Must Have (Launch Blockers):**
- ✅ Single parent can create family account
- ✅ Parent can categorize apps as learning/reward
- ✅ Child earns points for learning app time
- ✅ Child can convert points to reward time
- ✅ Family Controls enforces reward limits
- ✅ COPPA compliant
- ✅ App Store approved

**Nice to Have (Post-Launch):**
- ⏭️ Accessibility enhancements
- ⏭️ User onboarding flow
- ⏭️ Advanced analytics
- ⏭️ Multi-parent collaboration (v1.1)

---

## Contact

**Product Owner:** Sarah
**Architect:** Winston
**Project Manager:** [TBD]

**Questions?** Reference this handoff doc first, then PRD, then architecture doc. If still blocked, reach out to Product Owner.

---

**Document Version:** 1.0
**Last Updated:** 2025-09-23
**Status:** ✅ READY FOR DEVELOPMENT

🚀 **Let's build something amazing!**