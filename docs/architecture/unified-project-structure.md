# Unified Project Structure

```
ScreenTimeRewards/
├── ScreenTimeRewards/                      # Main iOS app
│   ├── App/
│   ├── Features/
│   │   ├── ParentDashboard/
│   │   ├── ChildDashboard/
│   │   ├── AppCategorization/
│   │   ├── RewardRedemption/
│   │   └── Settings/
│   └── Resources/
│
├── WidgetExtension/                        # Widget extension
│   ├── Widgets/
│   └── Providers/
│
├── AppIntentsExtension/                    # Siri shortcuts
│   └── Intents/
│
├── Packages/                               # Local Swift packages
│   ├── RewardCore/
│   ├── CloudKitService/
│   ├── FamilyControlsKit/
│   ├── SubscriptionService/
│   ├── DesignSystem/
│   ├── SharedModels/
│   └── AppIntents/
│
├── Tests/
├── Scripts/
├── Docs/
└── Package.swift
```

---
