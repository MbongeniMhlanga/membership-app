# Flutter Technical Assessment — Membership App

Build a Flutter app that lets users sign up, choose a membership tier, and upgrade it later. The app should show the features associated with the signed-in user's current membership. Use local data and simulated sign-in and upgrades.

## Requirements

1. **Data.** Use the supplied `users.json` to preload five mock profiles on first launch. Use `memberships.json` as the source of membership options and features. Match each user's `membershipId` to the corresponding membership `id`. Seed the profiles only once, even if all profiles are later deleted.
2. **State management.** Use Provider to manage the signed-in user, their current membership, and the features available to them.
3. **Sign-up and sign-in.** Collect a name and email address at sign-up and require the user to choose Starter, Plus, or Premium from the supplied membership data. Prevent duplicate email addresses. Allow both preloaded and newly registered users to sign in using their email address.
4. **Navigation.** Provide the three tabs described below.
5. **Upgrades.** Starter users can upgrade to Plus or Premium. Plus users can upgrade to Premium. Premium users should see a message explaining they are on the highest tier. Ask for confirmation before applying an upgrade. Once confirmed, save the new `membershipId` and update all three tabs immediately.
6. **Local persistence.** Use SharedPreferences or another local storage solution. Signing out ends the session. The same profile, latest membership, and corresponding features must be available when the user signs back in, including after an app restart. Keep each user's data independent.
7. **Profile deletion.** Let the signed-in user delete their own profile and return them to sign-in. A deleted profile, including a preloaded profile, must stay deleted after a restart. The user must sign up again to create a new profile. Other users' profiles must remain available.

| Tab | Expected behaviour |
| --- | --- |
| Home | Display the features for the current membership. Feature screens may be placeholders. |
| Membership | Display the current membership name and its included features. |
| Upgrade Membership | Show eligible higher tiers and their included features. Let the user select and confirm an upgrade. |

## What to demonstrate

- Sign in with test profiles covering all three tiers and show their different features.
- Sign up as a new user and select a membership.
- Upgrade a membership and show how the three tabs update.
- Sign out, restart the app, and sign back in to verify that the upgrade was saved.
- Delete a profile, restart the app, and verify that the deleted user cannot sign in while another user still can.

## Submission

Create a GitHub account if you do not already have one. Create a repository, push your Flutter project, and submit the **GitHub repository link**. Make sure the interview panel can access it. If the repository is private, invite the reviewers.

Include the complete Flutter source code, both supplied JSON files, and a `README.md` with setup instructions, the test account emails, and steps to verify the main flows.
