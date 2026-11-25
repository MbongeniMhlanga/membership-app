# Membership App

A Flutter membership app built for the technical assessment in `docs/Assessment.md`.

## Run

```bash
flutter pub get
flutter run
```

The app uses Provider for state and SharedPreferences for local persistence. On first launch it seeds the five supplied profiles from `docs/users.json`; tiers and features come from `docs/memberships.json`.

## Test accounts

- naledi.mokoena@example.com — Starter
- thabo.dlamini@example.com — Plus
- aisha.jacobs@example.com — Premium
- lerato.nkosi@example.com — Starter
- sipho.khumalo@example.com — Plus

Sign in requires only the email address. New profiles can be created from the sign-in screen.
