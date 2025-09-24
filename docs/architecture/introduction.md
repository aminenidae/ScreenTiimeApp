# Introduction

This document outlines the complete fullstack architecture for **Reward-Based Screen Time Management App**, including backend systems, frontend implementation, and their integration. It serves as the single source of truth for AI-driven development, ensuring consistency across the entire technology stack.

This unified approach combines what would traditionally be separate backend and frontend architecture documents, streamlining the development process for modern fullstack applications where these concerns are increasingly intertwined.

## Starter Template or Existing Project

**Decision: Greenfield iOS project with Apple ecosystem focus**

No starter template will be used. This allows us to build a pure Apple ecosystem solution using:
- Native SwiftUI for UI
- CloudKit for cloud storage and real-time sync
- Screen Time API for monitoring
- iCloud for authentication

This approach ensures optimal performance, native iOS aesthetics, and seamless integration with Apple services while maintaining COPPA compliance through Apple's established frameworks.

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-09-23 | 1.0 | Initial architecture document creation | Winston (Architect) |
| 2025-09-24 | 1.1 | Added StoreKit 2 subscription infrastructure (Epic 7) | Winston (Architect) |
