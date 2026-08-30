# Feed update log (master record)

Every change to this feed **must** append a row here and then run
`scripts/feed-verify.sh` — the verifier fails if a project index changed
after the log was last updated. Rows are newest first. The `Verified` column
means the update was re-checked after push (signature, checksums, index
integrity) by `scripts/feed-verify.sh` or an equivalent manual check.

| Date (UTC) | Project | Version | Action | Verified |
|---|---|---|---|---|
| 2026-08-30 | wificalling-location-gateway-beta | — | repository went private; its (empty, reserved) feed directory withheld from the public feed | ✅ feed-verify |
| 2026-08-30 | (repository) | — | renamed to `Smthdagg-Repo-feeds`; restructured to per-project directories (`wificalling-location-gateway/` holds the packages, 8 project dirs reserved); added `scripts/feed-verify.sh`; router feed URL migrated to the `wificalling-location-gateway/` subdirectory | ✅ feed-verify |
| 2026-08-29 | wificalling-location-gateway | 1.3.0-r13 | realistic memory gate (computed need + self-heal retry); standard + lite, x86_64 + aarch64 | ✅ |
| 2026-08-29 | wificalling-location-gateway | 1.3.0-r12 | auto-save applied manual locations; standard + lite, x86_64 + aarch64 | ✅ |
| 2026-08-29 | wificalling-location-gateway | 1.3.0-r11 | LuCI error-path hardening; standard + lite, x86_64 + aarch64 | ✅ |
| 2026-08-29 | wificalling-location-gateway | 1.3.0-r10 | audit hardening (upstream-map lifecycle, probe without curl); standard + lite, x86_64 + aarch64 | ✅ |
| 2026-08-29 | wificalling-location-gateway | 1.3.0-r9 | WLOC fail-open and low-memory node health; standard + lite, x86_64 + aarch64 | ✅ |
| 2026-08-24 | wificalling-location-gateway | 1.3.0-r1 | publish package source (standard + lite, x86_64 + aarch64; apk for 25.x) | ✅ |
| 2026-08-19 | wificalling-location-gateway | 1.2.2 | reject xhttp (sing-box unsupported) | ✅ |
| 2026-08-19 | wificalling-location-gateway | 1.2.2 | grpc/httpupgrade transport import fix | ✅ |
| 2026-08-19 | wificalling-location-gateway | 1.2.2 | monitor debounce, canonical version | ✅ |
| 2026-08-19 | wificalling-location-gateway | 1.2.2 | log clear via rpcd truncate | ✅ |
