# IoT Smart App

A Flutter IoT application for controlling smart devices and monitoring sensors via Firebase.

## App Preview
![App Screenshot](/preview.png)

## Features
- Control Red LED via Firebase
- Real-time temperature and humidity monitoring
- Beautiful dark theme UI
- Bottom navigation bar

## Screens
- **Home**: Welcome screen
- **Devices**: Control smart devices and view sensor data
- **Settings**: App configuration

## Setup Instructions

### Prerequisites
- Flutter SDK
- Firebase project

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Add your `google-services.json` to `android/app/`
4. Run `flutter run`

## Firebase Setup
1. Create Firebase project
2. Add Android app with package name `com.example.smart_app`
3. Download `google-services.json` and place in `android/app/`

## Build APK
```bash
'flutter build apk --release --split-per-abi'
