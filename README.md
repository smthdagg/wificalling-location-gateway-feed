# Smthdagg Repo feeds — OpenWrt package feed

Multi-project OpenWrt/opkg package feed, served at
`https://smthdagg.github.io/Smthdagg-Repo-feeds/`. Each project has its own
directory, its own `Packages` index, and its own signature — projects never
share an index.

**Rule: the directory name must exactly match the project's repository name.**
The verification script refuses an update whose directory does not follow
this rule, and `opkg update` on the router only sees the project whose
directory is referenced in `/etc/opkg/customfeeds.conf`.

## Layout

| Directory | Project | Status |
|---|---|---|
| `wificalling-location-gateway/` | smthdagg/wificalling-location-gateway | publishing (Standard + Lite, aarch64 + x86_64) |
| `luci-app-wificalling-gateway/` | smthdagg/luci-app-wificalling-gateway | reserved |
| `wificalling-location-gateway-beta/` | smthdagg/wificalling-location-gateway-beta | reserved (beta packages) |
| `ALL-VideoDownload-Plus/` | smthdagg/ALL-VideoDownload-Plus | reserved |
| `SalesCRM/` | smthdagg/SalesCRM | reserved |
| `Investment-Ann-List/` | smthdagg/Investment-Ann-List | reserved |
| `rsstt-app/` | smthdagg/rsstt-app | reserved |
| `XShield/` | smthdagg/XShield | reserved |
| `RSSTT-360News/` | smthdagg/RSSTT-360News | reserved |

`wloc.pub` at the root is the signing public key (key ID
`f7050198aa77cf15`, long-lived, does not change between releases).

## Update procedure (per project — follow exactly)

Work in a checkout of this repository's `gh-pages` branch. The index
generator is `scripts/gen-feed-index.sh` on this repository's `main` branch.

1. Copy the project's new `.ipk` files into `<project>/` (and remove
   superseded versions of the same package).
2. Regenerate **only that project's** index:
   `/tmp/wloc-feed-main/scripts/gen-feed-index.sh <project-dir>`
3. Sign it (macOS has no usign; the pinned OpenWrt rootfs runs it):
   `<product-repo>/scripts/openwrt/sign-feed.sh <project-dir>`
   **Never sign without regenerating the index first.**
4. Append a row to `UPDATES.md` (date, project, version, action).
5. Run `scripts/feed-verify.sh <project-parent-dir>` — it must pass before
   pushing. It verifies: `Packages.gz` matches `Packages`, both signatures
   are valid for the long-lived key, every indexed package exists with a
   matching SHA256, and `UPDATES.md` covers every project whose index changed
   after the log was last updated.
6. Commit and push `gh-pages`.

## Router configuration

One `src/gz` line per project, URL = feed base + project directory:

```sh
src/gz wloc https://smthdagg.github.io/Smthdagg-Repo-feeds/wificalling-location-gateway
```

Import the signing key once (never changes):

```sh
wget -O /etc/opkg/keys/f7050198aa77cf15 \
  https://raw.githubusercontent.com/smthdagg/Smthdagg-Repo-feeds/main/wloc.pub
```

OpenWrt 25.x uses the APK format: download the `.apk` asset from the
project's GitHub Release and `apk add --allow-untrusted` (the apk channel is
not separately signed).

## Repository rename note

This repository was renamed from `wificalling-location-gateway-feed` to
`Smthdagg-Repo-feeds` on 2026-08-30. The Pages URL changed accordingly; the
signing key and index format did not.
