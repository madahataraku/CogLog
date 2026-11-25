# CogLog fork notes

Upstream: [tutorial_coach_mark 1.3.4](https://pub.dev/packages/tutorial_coach_mark/versions/1.3.4).

## Patch

- Added `TargetFocus.enableTargetPassThrough`.
  - When true, the focus hole is clipped out of hit testing, the target `InkWell` is omitted, and the full-screen `InkWell` wrapper is skipped so widgets under the hole receive taps (goal-waiting tutorial step).
- Deferred `show` insert is cancellable (`_cancelled` / `removeOverlayEntry` before the post-frame callback).
- `postFrame` uses `WidgetsBinding.addPostFrameCallback` instead of `Future.delayed(Duration.zero)`.
- `disableBackButton` uses in-overlay `PopScope` (optional `onSystemBack`) instead of a modal `PageRouteBuilder`, so tutorial controls and pass-through keep working.
- Analyzer cleanups for Flutter 3.47: `withValues` instead of `withOpacity`, typed getters / `NotFoundTargetException`, drop unused `_contextTutorial`.
- Smoke tests for `enableTargetPassThrough` and `NotFoundTargetException` (empty `main()` failed CI with exit 79).
