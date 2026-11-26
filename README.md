# Membership App

A Flutter membership application built for the Flutter technical assessment in [`docs/Assessment.md`](docs/Assessment.md).

The app supports local sign-in, new member registration, membership upgrades, persistent profile data, and profile deletion. It uses the supplied JSON files as its local data source and does not require a backend.

## Features

- Seeds five supplied profiles on the first launch.
- Supports Starter, Plus, and Premium membership tiers.
- Displays tier-specific features on Home and Membership screens.
- Allows new users to register with a name, email address, and membership tier.
- Prevents duplicate email addresses and validates required sign-up fields.
- Allows Starter users to upgrade to Plus or Premium.
- Allows Plus users to upgrade to Premium.
- Shows a highest-tier message for Premium members.
- Persists profiles and membership upgrades with SharedPreferences.
- Supports sign-out and permanent self-service profile deletion.
- Provides animated hover states for web and desktop pointer devices.

## Requirements

- Flutter SDK with Dart 3 or later.
- Android Studio and an Android SDK for Android development, or Chrome/Windows for desktop testing.
- Java 21 for Android builds. If Flutter does not detect Java 21 automatically, configure it with the path to your local JDK 21 installation.

For Windows plugin builds, enable Developer Mode so Flutter can create symlinks:

```powershell
start ms-settings:developers
```

## Setup

Clone the repository and enter the project directory:

```powershell
git clone <repository-url>
cd membership-app
```

Configure Flutter to use Java 21 if needed. Replace `<path-to-jdk-21>` with your local JDK 21 installation path:

```powershell
flutter config --jdk-dir="<path-to-jdk-21>"
```

Install dependencies:

```powershell
flutter pub get
```

Check the local Flutter installation:

```powershell
flutter doctor
```

## Running the app

Run on the default available device:

```powershell
flutter run
```

Run explicitly on Chrome:

```powershell
flutter run -d chrome
```

Run explicitly on Windows:

```powershell
flutter run -d windows
```

Run on the Android emulator:

```powershell
flutter run -d emulator-5554
```

Hover effects are visible on Chrome and Windows. Android and other touch devices use tap interaction instead of mouse hover.

## Test accounts

Sign-in requires only the email address; there are no passwords.

| Email | Membership |
| --- | --- |
| `naledi.mokoena@example.com` | Starter |
| `thabo.dlamini@example.com` | Plus |
| `aisha.jacobs@example.com` | Premium |
| `lerato.nkosi@example.com` | Starter |
| `sipho.khumalo@example.com` | Plus |

## Assessment verification steps

### 1. Compare all membership tiers

1. Sign in as `naledi.mokoena@example.com` and open Home.
2. Confirm the Starter features are shown.
3. Sign out from the account menu.
4. Sign in as `thabo.dlamini@example.com` and confirm the Plus features.
5. Sign out and sign in as `aisha.jacobs@example.com`.
6. Confirm the Premium features and the highest-tier message on Upgrade.

### 2. Register a new member

1. Sign out if necessary.
2. Select **New here? Create an account**.
3. Enter a name and a new email address.
4. Select Starter, Plus, or Premium.
5. Select **Create my membership**.
6. Confirm that the new member is signed in and the selected features are visible.
7. Try the same email again to confirm duplicate registration is rejected.

### 3. Upgrade a membership

1. Sign in as a Starter or Plus user.
2. Open the **Upgrade** tab.
3. Confirm that only higher eligible tiers are shown.
4. Select an upgrade and confirm the dialog.
5. Confirm that Home, Membership, and Upgrade update immediately.

### 4. Verify persistence after restart

1. Upgrade a Starter or Plus account.
2. Sign out.
3. Stop and restart the application.
4. Sign back in with the same email.
5. Confirm that the latest membership and its features are still present.

### 5. Verify profile deletion and user isolation

1. Sign in with one test account.
2. Open the account menu and select **Delete profile**.
3. Confirm the deletion.
4. Restart the app and try to sign in with the deleted email; it must fail.
5. Sign in with another test account; it must still work.

## Project structure

```text
lib/
  main.dart              App initialization and Provider setup
  app.dart               Theme, navigation, screens, and UI components
  models.dart            Feature, Membership, and MemberUser models
  membership_store.dart  Provider state, authentication, and persistence

docs/
  Assessment.md          Technical assessment requirements
  memberships.json       Membership tiers and features
  users.json             Supplied seed profiles

test/
  membership_store_test.dart  State and persistence behavior tests
```

## Validation

Run static analysis and automated tests with:

```powershell
flutter analyze
flutter test
```

The automated tests cover seed data, sign-up validation, duplicate emails, upgrades, profile deletion, and user isolation.
