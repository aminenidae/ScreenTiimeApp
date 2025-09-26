#!/bin/bash

# Build script for ScreenTimeRewards debug build

echo "Starting ScreenTimeRewards debug build..."

# Clean previous builds
echo "Cleaning previous builds..."
cd ScreenTimeApp
xcodebuild -project ScreenTimeApp.xcodeproj -scheme ScreenTimeApp -configuration Debug -sdk iphonesimulator clean

# Build the project
echo "Building project..."
xcodebuild -project ScreenTimeApp.xcodeproj -scheme ScreenTimeApp -configuration Debug -sdk iphonesimulator build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "The app has been built for debugging in the iOS simulator."
else
    echo "Build failed. Please check the error messages above."
fi