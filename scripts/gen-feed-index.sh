#!/bin/sh
# Generate opkg (Packages/Packages.gz) and apk (APKINDEX.tar.gz) indexes for a
# directory of release packages, so the GitHub Release can act as a package
# source (src/gz).
#
# Usage: gen-feed-index.sh <package-directory>
set -eu

dir=${1:?usage: gen-feed-index.sh <package-directory>}
[ -d "$dir" ] || { echo "not a directory: $dir" >&2; exit 2; }
command -v opkg-utils >/dev/null 2>&1 || true

# opkg index (24.10 / iStoreOS)
if command -v opkg-make-index >/dev/null 2>&1; then
    (cd "$dir" && opkg-make-index . > Packages)
else
    python3 - "$dir" <<'PY'
import gzip, hashlib, os, pathlib, sys

def field(name, value):
    return f"{name}: {value}"

def summarize(ipk):
    import io, tarfile
    with gzip.open(ipk, "rb") as fh:
        outer = tarfile.open(fileobj=io.BytesIO(fh.read()), mode="r:")
        control = outer.extractfile("./control.tar.gz").read()
    inner = tarfile.open(fileobj=io.BytesIO(control), mode="r:gz")
    meta = {}
    for member in inner.getmembers():
        if member.name.endswith("/control"):
            text = inner.extractfile(member).read().decode()
            for line in text.splitlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    meta[k.strip()] = v.strip()
    return meta

root = pathlib.Path(sys.argv[1])
lines = []
for ipk in sorted(root.glob("*.ipk")):
    meta = summarize(ipk)
    size = ipk.stat().st_size
    sha = hashlib.sha256(ipk.read_bytes()).hexdigest()
    for key in ("Package", "Version", "Depends", "Provides", "Replaces", "Architecture"):
        if key in meta:
            lines.append(field(key, meta[key]))
    lines.append(field("Filename", ipk.name))
    lines.append(field("Size", size))
    lines.append(field("SHA256sum", sha))
    lines.append(field("Description", meta.get("Description", "")))
    lines.append("")
open(root / "Packages", "w").write("\n".join(lines))
with gzip.open(root / "Packages.gz", "wt") as fh:
    fh.write("\n".join(lines))
print("wrote", root / "Packages", "and", root / "Packages.gz")
PY
fi

# apk index (25.x): apk index -o APKINDEX.tar.gz <apk files>
if command -v apk >/dev/null 2>&1 && [ -n "$(ls "$dir"/*.apk 2>/dev/null || true)" ]; then
    (cd "$dir" && apk index -o APKINDEX.tar.gz *.apk)
    echo "wrote $(cd "$dir" && ls APKINDEX.tar.gz)"
fi
