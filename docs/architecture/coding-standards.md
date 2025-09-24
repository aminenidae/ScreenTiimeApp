# Coding Standards

## Critical Rules

- **Type Sharing:** Define types in `SharedModels` package
- **CloudKit Access:** Use repository protocols only
- **State Management:** ViewModels own `@Published` state
- **Error Handling:** All async operations handle errors

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Views | PascalCase + "View" | `ChildDashboardView` |
| ViewModels | PascalCase + "ViewModel" | `DashboardViewModel` |
| Protocols | PascalCase | `ChildProfileRepository` |
| Properties | camelCase | `pointBalance` |

---
