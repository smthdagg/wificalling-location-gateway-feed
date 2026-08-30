#!/bin/sh
# Verify the multi-project feed structure end to end:
#   - every project directory with a Packages index has a matching,
#     correctly signed Packages.gz;
#   - every indexed package file exists with a matching SHA256;
#   - UPDATES.md covers every project whose index changed after the log was
#     last updated (the "verify the log was recorded" rule).
# Usage: feed-verify.sh <feed-checkout-dir>
# Requires Docker (usign runs inside the pinned OpenWrt rootfs).

set -eu

OPENWRT_ROOTFS='ghcr.io/openwrt/rootfs:x86_64-24.10.8@sha256:9972a4b4747cd136abd597475d7b88c51a49fd849d0d53f069a2f4bf446061b9'
KEY_DIR=${WLOC_SIGN_KEY_DIR:-"$HOME/.zcode/keys"}

feed_dir=${1:?usage: feed-verify.sh <feed-checkout-dir>}
[ -d "$feed_dir" ] || { echo "feed-verify: not a directory: $feed_dir" >&2; exit 2; }
case "$feed_dir" in /*) ;; *) echo "feed-verify: directory must be absolute" >&2; exit 2;; esac
[ -f "$feed_dir/UPDATES.md" ] || { echo "feed-verify: missing $feed_dir/UPDATES.md" >&2; exit 1; }
[ -f "$KEY_DIR/wloc-signing.pub" ] || { echo "feed-verify: missing $KEY_DIR/wloc-signing.pub" >&2; exit 1; }

docker run --rm \
	-v "$KEY_DIR:/keys:ro" \
	-v "$feed_dir:/feed:ro" \
	--entrypoint /bin/sh \
	"$OPENWRT_ROOTFS" -c '
set -eu
cd /feed
fail=0
log=/feed/UPDATES.md
found=0
for d in */; do
	name=${d%/}
	[ -f "${d}Packages" ] || continue
	found=$((found + 1))
	gzip -dc "${d}Packages.gz" | cmp -s - "${d}Packages" || { echo "FAIL $name: Packages.gz does not match Packages"; fail=1; continue; }
	usign -V -q -p /keys/wloc-signing.pub -m "${d}Packages" -P "${d}Packages.sig" || { echo "FAIL $name: Packages signature invalid"; fail=1; }
	usign -V -q -p /keys/wloc-signing.pub -m "${d}Packages.gz" -P "${d}Packages.gz.sig" || { echo "FAIL $name: Packages.gz signature invalid"; fail=1; }
	( cd "$d" && awk "/^Filename:/{fn=\$2} /^SHA256sum:/{sha=\$2} fn!=\"\" && sha!=\"\" {print sha, fn; fn=\"\"; sha=\"\"}" Packages | while read -r sha fn; do
		[ -f "$fn" ] || { echo "FAIL $name: indexed package missing from the directory: $fn"; exit 1; }
		echo "$sha  $fn" | sha256sum -c - >/dev/null || { echo "FAIL $name: sha256 mismatch: $fn"; exit 1; }
	done ) || fail=1
	if [ "${d}Packages.gz" -nt "$log" ] && ! grep -q "$name" "$log"; then
		echo "FAIL $name: index changed after the last UPDATES.md entry — record it"
		fail=1
	fi
	echo "OK $name"
done
[ "$found" -ge 1 ] || { echo "FAIL: no project directory with a Packages index"; exit 1; }
exit $fail
'
