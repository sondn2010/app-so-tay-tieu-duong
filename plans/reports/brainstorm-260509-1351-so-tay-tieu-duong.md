# Brainstorm Report: Sổ Tay Tiểu Đường

**Date:** 2026-05-09  
**Type:** App Architecture Design

---

## Problem Statement

Build a Flutter mobile app "Sổ tay tiểu đường" (Diabetes Notebook) for diabetic patients (iOS + Android), fully offline-first, with 3 equal-priority modules launched simultaneously at v1.0.

---

## Requirements

| # | Requirement |
|---|------------|
| R1 | Sổ tay kiến thức — articles/content về tiểu đường, bundle + remote update |
| R2 | Thuốc & Bữa ăn — quản lý liều dùng theo buổi, nutrition tracking đơn giản |
| R3 | Nhật ký đường huyết — nhập chỉ số, biểu đồ, cảnh báo ngưỡng màu đỏ |
| R4 | Offline-first, toàn bộ data local |
| R5 | iOS + Android |
| R6 | Stitch MCP dùng để generate UI components |
| R7 | Sources trong `src/` |

---

## Approaches Evaluated

### A (Chosen): Feature-Folder + Riverpod + Isar
- Simple flat feature structure, state via Riverpod, local DB via Isar
- KISS compliant, fast iteration, Stitch-generated UI integrates naturally
- Offline-first by default

### B: Clean Architecture (Domain/Data/Presentation per feature)
- Overkill boilerplate for this scope — violates YAGNI

### C: Dart Monorepo Packages
- Over-engineered for a single-team MVP app

---

## Final Solution: Option A

### Tech Stack

| Concern | Package |
|---------|---------|
| State | `riverpod` + `flutter_riverpod` |
| Local DB | `isar` |
| Charts | `fl_chart` |
| Navigation | `go_router` |
| Notifications | `flutter_local_notifications` |
| HTTP | `dio` (remote knowledge fetch) |
| Local cache | `shared_preferences` (light prefs) + Isar |
| UI generation | Stitch MCP (Google) |

### Source Structure

```
src/
├── features/
│   ├── knowledge/          # Sổ tay kiến thức
│   │   ├── data/
│   │   ├── providers/
│   │   └── screens/
│   ├── medication/         # Thuốc & Bữa ăn
│   │   ├── data/
│   │   ├── providers/
│   │   └── screens/
│   └── blood_sugar/        # Nhật ký đường huyết
│       ├── data/
│       ├── providers/
│       └── screens/
├── core/
│   ├── database/           # Isar init + schemas
│   ├── notifications/      # Notification service
│   ├── theme/              # Color tokens, typography
│   └── widgets/            # Shared components
├── app.dart
└── main.dart
```

### Blood Sugar Alert Thresholds

```
< 70 mg/dL      → Hạ đường huyết (RED - critical)
70–99           → Bình thường (GREEN)
100–125         → Tiền tiểu đường (YELLOW - warn)
≥ 126 mg/dL     → Cao (RED - alert)
```

### Knowledge Base Strategy

1. Bundle `assets/knowledge/*.json` → always available offline
2. On app launch (background): fetch remote JSON from CDN/GitHub raw
3. Cache fetched content in Isar → serve from Isar
4. Fallback to bundled if no network / fetch fails

### Stitch MCP Workflow

1. Describe screen (e.g., "Blood sugar entry form with time picker and value input")
2. Stitch generates Flutter widget tree
3. Integrate into `screens/` folder
4. Wire Riverpod providers

---

## Risks

| Risk | Mitigation |
|------|-----------|
| Isar schema migrations | Plan schema upfront; use Isar migration API |
| Notification permissions (iOS) | Request at onboarding, graceful fallback |
| Knowledge content quality | Human-curated JSON, medical review before bundle |
| Remote JSON format changes | Versioned JSON schema (`"version": 1`) |

---

## Success Criteria

- [ ] Nhập chỉ số đường huyết → hiển thị chart + color alert trong < 1s
- [ ] Nhắc uống thuốc đúng giờ (local notification)
- [ ] Đọc bài kiến thức offline sau khi cài app lần đầu
- [ ] App khởi động < 2s trên mid-range device
- [ ] Zero crash on happy path (blood sugar entry, medication log, article read)
