---
title: Sổ Tay Tiểu Đường — Flutter App
status: in_progress
created: 2026-05-09
blockedBy: []
blocks: []
---

# Sổ Tay Tiểu Đường — Implementation Plan

**Brainstorm report:** `plans/reports/brainstorm-260509-1351-so-tay-tieu-duong.md`  
**UI designs:** `docs/UI/` (PNG + HTML mockups + DESIGN.md)

## Overview

Offline-first Flutter app (iOS + Android) for diabetic patients. **4-tab navigation**: Trang chủ | Nhật ký | Kiến thức | Hồ sơ. Trợ lý AI deferred to v2.

**Stack:** Flutter + Riverpod + Isar + fl_chart + go_router + flutter_local_notifications + dio + image_picker  
**UI generation:** Stitch MCP (Google) — always reference `docs/UI/*.html` + DESIGN.md when generating  
**Source root:** `src/`

---

## UI Reference

| Screen | Mockup files | Tab |
|--------|-------------|-----|
| Home dashboard | `docs/UI/0_home.png` + `0_home.html` | Trang chủ |
| Blood sugar diary | `docs/UI/2_nhatky.png` + `2_nhatky.html` | Nhật ký |
| Knowledge list | `docs/UI/4_sotaykienthuc.png` + `4_sotaykienthuc.html` | Kiến thức |
| User profile | `docs/UI/5_hosonguoidung.png` + `5_hosonguoidung.html` | Hồ sơ |
| Design system | `docs/UI/DESIGN.md` | — |

### Design Theme: "Pencil & Paper"

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#fcf9f3` | All screens warm paper |
| Primary | `#35675b` | Nav active, headings, buttons |
| Secondary container | `#fddc9a` | Medication banner bg |
| Tertiary | `#8b4c50` | Danger/alert accents |
| Error | `#ba1a1a` | Abnormal blood sugar, delete |
| Font | Be Vietnam Pro | All weights |
| Card style | `sketch-border` / `hand-drawn-border` | Organic borders, ±0.5° rotation |

---

## Multi-Agent Execution Strategy

```
┌────────────────────────────────────────────────────────────────┐
│                      COORDINATOR AGENT                         │
│  Phase 01 (Setup) → Phase 02 (Core Infra)                      │
│  → spawns 3 parallel agents → Phase 07 (Home) → Phase 08      │
└───────────────────┬────────────────────────────────────────────┘
                    │  after Phase 02 complete
       ┌────────────┼──────────────┐
       ▼            ▼              ▼
 ┌──────────┐  ┌──────────┐  ┌───────────────────┐
 │ AGENT 1  │  │ AGENT 2  │  │     AGENT 3        │
 │  Blood   │  │  Meds    │  │  Knowledge +       │
 │  Sugar   │  │ & Meals  │  │  User Profile      │
 │ Phase 03 │  │ Phase 04 │  │  Phase 05 + 06     │
 └──────────┘  └──────────┘  └───────────────────┘
       └────────────┼──────────────┘
                    ▼  all 3 done
           ┌──────────────────┐
           │   COORDINATOR    │
           │  Phase 07 (Home) │
           │  Phase 08 (Polish│
           └──────────────────┘
```

### Phase 02 Completion Signal (V7)

Coordinator signals Phase 02 complete by:
1. Running `flutter analyze` → 0 errors
2. Git committing Phase 02 code with message `feat: Phase 02 core infrastructure complete`
3. Parallel agents begin **after** this commit is visible on the branch

### File Ownership (CRITICAL — no overlap)

| Agent | Owns | Must NOT touch |
|-------|------|----------------|
| Coordinator | `core/**`, `features/home/**`, `app.dart`, `main.dart` | Feature folders during parallel phase |
| Agent 1 | `features/blood_sugar/**` | core/, medication/, knowledge/, profile/, home/ |
| Agent 2 | `features/medication/**` | core/, blood_sugar/, knowledge/, profile/, home/ |
| Agent 3 | `features/knowledge/**`, `features/profile/**`, `assets/knowledge/**` | core/, blood_sugar/, medication/, home/ |

> All Isar schemas + schema additions collected by **Coordinator before spawning agents**.  
> Parallel agents implement repository/providers/screens/widgets on top of existing schemas.

### Schema Additions (Coordinator collects, applies in Phase 02)

| Schema change | Needed by |
|--------------|-----------|
| Add `DoseLogSchema` | Phase 04 |
| Add `Article.readTimeMinutes: int` | Phase 05 |
| Add `Article.isFavorite: bool` | Phase 05 |

### Stitch MCP Prompt Template

When generating any screen with Stitch, always include:
```
Design system: docs/UI/DESIGN.md — "Pencil & Paper" theme
Reference HTML: docs/UI/<screen>.html
Colors: primary=#35675b, background=#fcf9f3, secondary-container=#fddc9a, error=#ba1a1a
Font: Be Vietnam Pro
Card style: sketch-border with ±0.5deg rotation, box-shadow 2px 2px 0 rgba(53,103,91,0.2)
```

---

## Phases

| # | Phase | Agent | Status | Depends On |
|---|-------|-------|--------|------------|
| 1 | [Project Setup](phase-01-project-setup.md) | Coordinator | pending | — |
| 2 | [Core Infrastructure](phase-02-core-infrastructure.md) | Coordinator | pending | Phase 01 |
| 3 | [Blood Sugar Module](phase-03-blood-sugar-module.md) | Agent 1 | pending | Phase 02 |
| 4 | [Medication & Meals](phase-04-medication-meals-module.md) | Agent 2 | pending | Phase 02 |
| 5 | [Knowledge Base](phase-05-knowledge-base-module.md) | Agent 3 | pending | Phase 02 |
| 6 | [User Profile](phase-06-user-profile.md) | Agent 3 | pending | Phase 02 |
| 7 | [Home Dashboard](phase-07-home-dashboard.md) | Coordinator | pending | Phase 03+04 |
| 8 | [Integration & Polish](phase-08-integration-polish.md) | Coordinator | pending | Phase 05+06+07 |

## Source Structure

```
src/lib/
├── features/
│   ├── blood_sugar/       ← Agent 1  (ref: 2_nhatky.html)
│   │   ├── data/
│   │   ├── providers/
│   │   └── screens/
│   ├── medication/        ← Agent 2  (ref: 0_home.html)
│   │   ├── data/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/       # MedicationReminderBanner
│   ├── knowledge/         ← Agent 3  (ref: 4_sotaykienthuc.html)
│   │   ├── data/
│   │   ├── providers/
│   │   └── screens/
│   ├── profile/           ← Agent 3  (ref: 5_hosonguoidung.html)
│   │   ├── data/
│   │   ├── providers/
│   │   └── screens/
│   ├── home/              ← Coordinator  (ref: 0_home.html)
│   │   ├── data/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/       # BloodSugarMiniChart
│   └── onboarding/        ← Coordinator
│       └── screens/
├── core/                  ← Coordinator only
│   ├── config/            # AppConfig (remote URL)
│   ├── database/          # Isar init + all schemas
│   ├── notifications/     # NotificationService
│   ├── theme/             # AppColors, AppTheme, BloodSugarStatus
│   └── widgets/           # PaperCard, LoadingIndicator, EmptyState, ErrorView, BloodSugarNumpad, ScaffoldWithBottomNav
├── app.dart               ← Coordinator
└── main.dart              ← Coordinator
```

## 4-Tab Navigation

| Tab | Route | Screen |
|-----|-------|--------|
| Trang chủ | `/home` | `HomeScreen` |
| Nhật ký | `/diary` | `BloodSugarDiaryScreen` |
| Kiến thức | `/knowledge` | `ArticleListScreen` |
| Hồ sơ | `/profile` | `ProfileScreen` |

## Key Feature Summary (from UI audit)

| Feature | Phase | UI Source |
|---------|-------|-----------|
| Custom numpad entry | 03 | `2_nhatky.html` |
| mg/dL ↔ mmol/L toggle | 03 | `2_nhatky.html` |
| Abnormal value red-circle badge | 03 | `2_nhatky.html` |
| Computed chart insight text | 03 | `2_nhatky.html` |
| Dose mark-as-done (XONG) | 04 | `0_home.html` |
| Daily dose counter X/Y | 04 | `0_home.html` |
| Favorite articles (heart) | 05 | `4_sotaykienthuc.html` |
| Correct 7 categories | 05 | `4_sotaykienthuc.html` |
| Read time on articles | 05 | `4_sotaykienthuc.html` |
| Target blood sugar range | 06 | `5_hosonguoidung.html` |
| Avatar edit | 06 | `5_hosonguoidung.html` |
| Sign-out | 06 | `5_hosonguoidung.html` |
| Blood sugar mini bar chart | 07 | `0_home.html` |
| Steps counter (manual) | 07 | `0_home.html` |
| Daily inspirational quote | 07 | `0_home.html` |

## Validation Log

### Session 1 — 2026-05-09
**Trigger:** Post red-team validation interview  
**Questions asked:** 7

#### Questions & Answers

1. **[Architecture]** Global `late Isar isar` vs Riverpod `isarProvider`
   - Options: Keep global | Riverpod isarProvider now | Singleton class
   - **Answer:** Riverpod isarProvider now
   - **Rationale:** Enables unit testing and safe migration handling. All repo providers now use `ref.watch(isarProvider)`. Override set in main() ProviderScope.

2. **[Scope]** Knowledge sync backend target
   - Options: GitHub Pages | Supabase | Skip remote sync v1 | Custom API
   - **Answer:** GitHub Pages / raw.githubusercontent.com
   - **Rationale:** Keep existing approach; replace `your-org` placeholder before release. No backend work needed for v1.

3. **[Assumptions]** Blood sugar input validation range
   - Options: 20–600 mg/dL | 40–500 mg/dL | 1–999 mg/dL
   - **Answer:** 20–600 mg/dL
   - **Rationale:** Clinically appropriate. Validates in entry screen before save. Added rejection tests.

4. **[Scope]** `image_picker` dependency ownership
   - Options: Phase 01 pubspec | Phase 02 | Agent 3 signals Coordinator
   - **Answer:** Phase 01 pubspec
   - **Rationale:** Coordinator adds all deps upfront. No mid-parallel coordination needed.

5. **[Architecture]** go_router redirect per-navigation I/O
   - Options: Cache in StateProvider | Keep async SharedPrefs | refreshListenable
   - **Answer:** Cache in Riverpod StateProvider
   - **Rationale:** `onboardedProvider` initialized in main() from SharedPrefs, passed via ProviderScope override. Router redirect is synchronous.

6. **[Scope]** Wide-card article layout when `imageUrl == null`
   - Options: Only wide if imageUrl != null | Placeholder color block | Remove wide-card
   - **Answer:** Only wide if imageUrl != null
   - **Rationale:** No empty gray boxes on null images. Simple one-line guard.

7. **[Architecture]** Multi-agent Phase 02 completion signal
   - Options: Git commit | Coordinator sends message | Agents check file existence
   - **Answer:** Git commit on Phase 02 branch
   - **Rationale:** Clear, auditable signal. Agents pull the commit, see `flutter analyze` clean, then begin. Documented in plan.md execution strategy.

#### Confirmed Decisions
- **isarProvider**: Riverpod provider, overridden in ProviderScope — all phases updated
- **Content backend**: GitHub raw URL, replace `your-org` before release
- **BS validation**: 20–600 mg/dL enforced in entry screen
- **image_picker**: Added to Phase 01 pubspec by Coordinator
- **Router redirect**: Synchronous via `onboardedProvider` StateProvider
- **Wide card**: Guarded with `article.imageUrl != null`
- **Agent start signal**: Git commit after `flutter analyze` 0 errors on Phase 02

#### Action Items
- [x] Phase 02: `isarProvider` replaces global `late Isar isar`
- [x] Phase 01: `image_picker` added to pubspec.yaml
- [x] Phase 02: `onboardedProvider` defined, initialized in main()
- [x] Phase 03: Blood sugar entry validates 20–600 mg/dL
- [x] Phase 04: All repo providers use `ref.watch(isarProvider)`
- [x] Phase 05: Wide-card guarded with `imageUrl != null`
- [x] Phase 06: Sign-out uses `ref.read(isarProvider)` not global
- [x] Phase 08: Router redirect uses `onboardedProvider` synchronously
- [x] plan.md: Agent coordination signal documented

#### Impact on Phases
- Phase 01: Added `image_picker` to pubspec
- Phase 02: `isarProvider`, `onboardedProvider`, `initIsar()` returns `Isar`
- Phase 03: Input validation 20–600 + `ref.watch(isarProvider)`
- Phase 04: `ref.watch(isarProvider)` in all providers; sync fn accepts `Isar db`
- Phase 05: `ref.watch(isarProvider)` + wide-card guard
- Phase 06: `ref.watch(isarProvider)` + sign-out via `ref.read`
- Phase 08: Sync router redirect

---

## Red Team Review

### Session — 2026-05-09
**Findings:** 15 (15 accepted, 0 rejected)  
**Severity breakdown:** 7 Critical, 8 High

| # | Finding | Severity | Disposition | Applied To |
|---|---------|----------|-------------|------------|
| 1 | Schema deferred to Phase 08 — parallel agents can't compile | Critical | Accept | Phase 02 |
| 2 | `stepsRepoProvider` async type error — won't compile | Critical | Accept | Phase 07 |
| 3 | `_nextInstanceOf()` undefined + timezone never initialized | Critical | Accept | Phase 02 |
| 4 | `Article.fromJson` never defined | Critical | Accept | Phase 05 |
| 5 | `syncFromRemote` resets `isFavorite` on every sync | Critical | Accept | Phase 05 |
| 6 | `nextPendingDose()` body is ellipsis | Critical | Accept | Phase 04 |
| 7 | Unauthenticated GitHub URL — medical content injection | Critical | Accept | Phase 05 |
| 8 | Sign-out clears SharedPrefs only — Isar health data survives | High | Accept | Phase 06 |
| 9 | Android 13+ POST_NOTIFICATIONS permission never requested | High | Accept | Phase 02, Phase 08 |
| 10 | `getStatus()` hardcoded thresholds — ignores custom target range | High | Accept | Phase 02, Phase 03 |
| 11 | Meal Log module orphaned — no screen consumes data | High | Accept | Phase 04 |
| 12 | CSS organic border-radius unimplementable in Flutter | High | Accept | Phase 03 |
| 13 | `bloodSugarUnitProvider` hardcoded — SharedPrefs never read | High | Accept | Phase 02, Phase 03 |
| 14 | `seedFromAssets` one-way guard blocks content updates | High | Accept | Phase 05 |
| 15 | `NotificationService.cancelAll()` race during concurrent sync | High | Accept | Phase 04 |

---

## Success Criteria

- [ ] All 4 screens match `docs/UI/*.png` mockups visually
- [ ] Blood sugar entry → chart + color alert < 1s
- [ ] Medication reminders fire via local notifications
- [ ] Knowledge articles readable offline from first install
- [ ] App cold start < 2s on mid-range device
- [ ] `flutter analyze` 0 errors + `flutter build apk --release` succeeds
