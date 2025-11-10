# RCG Mobile App - React Native + Salesforce Mobile SDK

This is the React Native mobile app for Field Sales Representatives, built on Salesforce Mobile SDK.

## Prerequisites

- Node.js 18+
- React Native CLI
- Xcode (for iOS) or Android Studio (for Android)
- Salesforce Mobile SDK

## Setup

1. Install dependencies:
```bash
cd mobile/app
npm install
```

2. Install iOS pods:
```bash
cd ios && pod install && cd ..
```

3. Configure Connected App:
   - Copy `.env.example` to `.env`
   - Update `SF_CONSUMER_KEY` and `SF_REDIRECT_URI`

## Running

**iOS:**
```bash
npm run ios
```

**Android:**
```bash
npm run android
```

## Features

### Offline-First Architecture
- SmartStore for encrypted local storage
- SmartSync for bidirectional sync with conflict resolution
- Background sync queue with retry logic

### Key Screens
- **Home**: KPI dashboard
- **Beat Today**: Daily route with map
- **Visit**: Check-in, activities, check-out
- **Order Cart**: Barcode scan, UoM picker, promo preview
- **Sync Center**: Manual sync with conflict viewer

### Device Integrations
- Camera for photo capture (evidence, POSM, signatures)
- Barcode scanner (GS1, EAN-13, UPC-A, Code-128)
- GPS for geofenced check-in
- Background location tracking

## Testing

```bash
npm test
```

## Build for Release

**iOS:**
```bash
cd ios
xcodebuild -workspace RCGMobile.xcworkspace -scheme RCGMobile -configuration Release
```

**Android:**
```bash
cd android
./gradlew assembleRelease
```

## Troubleshooting

See main README.md for common issues and solutions.
