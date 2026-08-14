# Contributing to Watch Your Language

Thank you for helping improve Watch Your Language. Bug fixes, accessibility
improvements, documentation and carefully scoped features are welcome.

## Before you start

- Search the existing issues before opening a new one.
- For a larger change, open an issue first so the approach can be discussed.
- Do not include private health information or real communication phrases in
  issues, screenshots, test data or commits.
- Report security or privacy concerns privately using the instructions in
  [SECURITY.md](SECURITY.md), not through a public issue.

## Development setup

The project requires macOS with Xcode 26.6, the iOS 26.5 SDK and the watchOS
26.5 SDK. Open `WatchYourLanguageAAC.xcodeproj` and run the
`WatchYourLanguageAAC` scheme. The Apple Watch target can be run separately or
as part of a paired iPhone and Apple Watch simulator.

There are no third-party package dependencies or setup secrets.

## Design and accessibility principles

Watch Your Language is used during real conversations, often under time or
communication pressure. Changes should preserve:

- large, legible text and strong colour contrast;
- clear labels and generous touch targets;
- support for VoiceOver and Dynamic Type where the platform permits it;
- plain, specific language;
- a person's control over what the app displays and speaks;
- local-first storage, with no analytics, advertising or developer-operated
  account requirement; and
- reliable behaviour when the phone, watch or network is unavailable.

The interface uses Atkinson Hyperlegible and a transport-signage-inspired
design system. New UI should use the shared components and palette unless a
change to that system is part of the proposal.

## Pull requests

Please keep each pull request focused. Include:

- a short description of the problem and the change;
- the iPhone and/or Apple Watch configurations tested;
- screenshots or a short recording for visible interface changes; and
- any accessibility or privacy implications.

Before submitting, build each affected target and check the changed flow with
VoiceOver where practical. Tests and documentation should be updated when the
behaviour they describe changes.
