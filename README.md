# Standalone WLOC Gateway — OpenWrt feed

Prebuilt package source for the standalone
[`wificalling-location-gateway`](https://github.com/smthdagg/wificalling-location-gateway)
product. V2 unifies the WLOC service lifecycle and management UI in one
package. It is independent of the separate Wi-Fi Calling Gateway project.

## Supported platforms

Each target ships both **Standard** (reuses the firmware/feed `sing-box`) and
**Lite** (bundled, hash-pinned `sing-box`) variants.

| Platform | Standard | Lite |
|---|---|---|
| Redmi AX6S / MT7622 / AArch64 (cortex-a53) | `wificalling-location-gateway_1.3.0-r1_aarch64_cortex-a53.ipk` | `wificalling-location-gateway-lite_1.3.0-r1_aarch64_cortex-a53.ipk` |
| OpenWrt 24.10 / iStoreOS 24.10 / x86-64 | `wificalling-location-gateway_1.3.0-r1_x86_64.ipk` | `wificalling-location-gateway-lite_1.3.0-r1_x86_64.ipk` |
| OpenWrt 25.x / x86-64 (APK) | `wificalling-location-gateway-1.3.0-r1.apk` | `wificalling-location-gateway-lite-1.3.0-r1.apk` |

## Install from the package source

Import the repository signing key once (the key is **long-lived and does not
change between releases**), add the source, and install the
architecture-matching package:

```sh
wget -O /etc/opkg/keys/f7050198aa77cf15 \
  https://raw.githubusercontent.com/smthdagg/wificalling-location-gateway-feed/main/wloc.pub
echo "src/gz wloc https://smthdagg.github.io/wificalling-location-gateway-feed" \
  >> /etc/opkg/customfeeds.conf
opkg update
opkg install wificalling-location-gateway          # Standard
# opkg install wificalling-location-gateway-lite  # Lite (bundled sing-box)
```

OpenWrt 25.x uses the APK package format. For that platform, download
`wificalling-location-gateway-1.3.0-r1.apk` (or the `-lite-` variant), verify it
against `SHA256SUMS`, and install it with `apk add --allow-untrusted` (the apk
source is not separately signed; the opkg source above is signed).

## AX6S migration

On storage-constrained AX6S devices, back up the WLOC UCI configuration and
CA first, stop and disable the old WLOC application package, remove the old
application package, recheck free space, then install the architecture-
matching V2 package. Do not remove or duplicate the selected tiny/lite/
PassWall sing-box provider; V2 reuses that provider.

The package preserves compatible UCI configuration as an OpenWrt conffile.
After installation, verify the standalone service, LuCI status, provider
health, redirect scope, and rollback path before enabling interception.

## Verification and rollback

Each release includes `SHA256SUMS`, `Packages`, and signed `Packages`/
`Packages.gz` indexes. Verify the package checksum before installation and
keep the previous architecture-matching package for rollback. To roll back,
withdraw WLOC interception first, restore the previous package and UCI
backup, then confirm the separate provider remains untouched.

The feed does not contain the separate Wi-Fi Calling Gateway package and does
not require that project at install or runtime.
