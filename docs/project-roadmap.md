# Project Roadmap - Sổ Tay Tiểu Đường

## Overview

This document tracks the development roadmap for the Sổ Tay Tiểu Đường Flutter app. Phase milestones and progress are updated as features are implemented.

## Current Status

**Active Phase**: Phase 6 - Core Features Complete
**Last Updated**: 2026-05-09

---

## Phase Roadmap

### Phase 1: Project Setup

**Status**: COMPLETE

| Task | Status |
|------|--------|
| Initialize Flutter project | DONE |
| Configure pubspec.yaml | DONE |
| Set up directory structure | DONE |

### Phase 2: Core Infrastructure

**Status**: COMPLETE

| Task | Status |
|------|--------|
| Implement Isar database | DONE |
| Create shared widgets | DONE |
| Configure theme | DONE |
| Set up GoRouter | DONE |
| Add notification service | DONE |

### Phase 3: Blood Sugar Feature

**Status**: COMPLETE

| Task | Status |
|------|--------|
| BloodSugarEntry model | DONE |
| Repository + providers | DONE |
| Entry screen with numpad | DONE |
| Diary screen | DONE |
| Mini chart | DONE |

### Phase 4: Medication Feature

**Status**: COMPLETE

| Task | Status |
|------|--------|
| Medication model | DONE |
| DoseLog model | DONE |
| Repository + providers | DONE |
| List screen | DONE |
| Form screen | DONE |
| Notification sync | DONE |

### Phase 5: Knowledge Feature

**Status**: COMPLETE

| Task | Status |
|------|--------|
| Article model | DONE |
| Repository + providers | DONE |
| List screen | DONE |
| Detail screen | DONE |
| Remote sync | DONE |

### Phase 6: Profile & Onboarding

**Status**: COMPLETE

| Task | Status |
|------|--------|
| UserProfile model | DONE |
| Repository + providers | DONE |
| Onboarding screen | DONE |
| Profile screen | DONE |
| Edit profile screen | DONE |
| Data sync screen | DONE |
| Help screen | DONE |

### Phase 7: Polish & Quality

**Status**: IN PROGRESS

| Task | Status |
|------|--------|
| Error handling | IN PROGRESS |
| Loading states | PENDING |
| Empty states | PENDING |
| Edge cases | PENDING |

### Phase 8: Testing

**Status**: PENDING

| Task | Status |
|------|--------|
| Unit tests | PENDING |
| Widget tests | PENDING |
| Integration tests | PENDING |

### Phase 9: Release Prep

**Status**: PENDING

| Task | Status |
|------|--------|
| App icons | PENDING |
| Splash screen | PENDING |
| Build verification | PENDING |
| Store listing | PENDING |

---

## Feature Backlog

### Priority 1 - Must Have

- [ ] Analytics tracking
- [ ] Data export (JSON)
- [ ] Reminder snooze

### Priority 2 - Should Have

- [ ] Dark mode
- [ ] Multiple profiles
- [ ] Weekly summary

### Priority 3 - Nice to Have

- [ ] Cloud backup
- [ ] WearSync integration
- [ ] Apple Health / Google Fit

---

## Known Issues

| Issue | Severity | Status |
|-------|----------|--------|
| No unit tests | HIGH | Pending |
| No analytics | MEDIUM | Backlog |
| Hardcoded remote URL | LOW | Fixed in next release |

## Dependencies

**Production**:
- `flutter_riverpod: ^2.5.1`
- `isar: ^3.1.0`
- `go_router: ^13.2.0`
- `dio: ^5.4.3`
- `flutter_local_notifications: ^17.2.2`
- `fl_chart: ^0.68.0`
- `shared_preferences: ^2.2.3`

**Development**:
- `build_runner`
- `isar_generator`

---

## Changelog

### v1.0.0 (2026-05-09)

- Initial release
- Blood sugar tracking with diary
- Medication reminders
- Knowledge articles
- User profile
- Onboarding flow

---

*Last updated: 2026-05-09*