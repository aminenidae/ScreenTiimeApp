# App Store Connect Configuration

This directory contains the configuration files for App Store Connect integration.

## Configuration Files

- `config.json` - Main App Store Connect configuration
- `metadata/` - App metadata templates
- `screenshots/` - Screenshot templates and placeholders

## Setup Instructions

1. Create an App Store Connect account if you don't have one
2. Create a new app record using the bundle ID specified in config.json
3. Upload the metadata from the metadata/ directory
4. Prepare screenshots according to the device types specified
5. Configure TestFlight groups as specified in the config.json

## Bundle Identifier

The bundle identifier for this app is: `com.screentimerewards.app`

## Important Notes

- Family Controls entitlement requires special approval from Apple
- App Store Review Guidelines must be followed for screen time apps
- Privacy policy is mandatory and must be accessible
- COPPA compliance is required for children under 13