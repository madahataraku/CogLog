# CogLog fork notes

Upstream: [tutorial_coach_mark 1.3.4](https://pub.dev/packages/tutorial_coach_mark/versions/1.3.4).

## Patch

- Added `TargetFocus.enableTargetPassThrough`.
- When true, the focus hole is clipped out of hit testing and the target `InkWell` is omitted so widgets under the hole receive taps (goal-waiting tutorial step).
