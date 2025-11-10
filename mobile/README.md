# RCG Mobile App (React Native + Salesforce Mobile SDK)

React Native mobile application for Field Sales Reps with offline capability using Salesforce Mobile SDK.

## Prerequisites

- Node.js 18+
- React Native CLI
- Xcode (iOS) or Android Studio (Android)
- Salesforce Mobile SDK

## Setup

1. **Install dependencies**
   ```bash
   cd mobile
   npm install
   ```

2. **Configure Salesforce**
   - Update `.env` with your Salesforce org credentials
   - Configure Connected App in Salesforce org

3. **Run iOS**
   ```bash
   ./scripts/mobile-run-ios.sh
   ```

4. **Run Android**
   ```bash
   ./scripts/mobile-run-android.sh
   ```

## Features

- Offline-first with SmartStore/SmartSync
- OAuth2 authentication with SSO support
- Barcode scanning
- Camera capture with compression
- Geo-fenced check-in
- Background sync
- Deep linking

## Architecture

- **State Management**: Redux Toolkit
- **Navigation**: React Navigation
- **Offline Storage**: Salesforce SmartStore
- **Sync**: Salesforce SmartSync
- **Camera**: react-native-vision-camera
- **Location**: @react-native-community/geolocation

## Data Model

Local SmartStore soups:
- Products
- Retailers
- BeatStops
- Visits
- OrderDrafts
- InventorySnapshots
- SyncQueue

## Sync Strategy

- **Sync Down**: Products, Pricebooks, Promotions, BeatStops, Retailers
- **Sync Up**: Visits, Activities, Orders, InventorySnapshots, Photos, Claims

## Troubleshooting

- **Build failures**: Ensure pods/gradle dependencies are installed
- **Auth issues**: Verify Connected App configuration
- **Sync issues**: Check network connectivity and SmartStore initialization
