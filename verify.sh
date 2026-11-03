#!/bin/bash
# Verify this package: recompute sha256 of every COPIED file (group PUBLIC-TEXT in FILE_LIST.tsv) and compare with the
# recorded hash. HASH-ONLY groups document hashes of files that are not in the package and are not checked here.
# Exit 0 only if every listed public file is present with the recorded hash; otherwise exit 1.
cd "$(dirname "$0")" || exit 2
[ -f FILE_LIST.tsv ] || { echo "MISSING   FILE_LIST.tsv (cannot verify anything)"; exit 1; }
if command -v sha256sum >/dev/null 2>&1; then H() { sha256sum "$1" | cut -d' ' -f1; }; else H() { shasum -a 256 "$1" | cut -d' ' -f1; }; fi
ok=0; bad=0
while IFS=$'\t' read -r group sha bytes path; do
  [ "$group" = "PUBLIC-TEXT" ] || continue
  if [ ! -f "$path" ]; then echo "MISSING   $path"; bad=$((bad+1)); continue; fi
  if [ "$(H "$path")" = "$sha" ]; then echo "OK        $path"; ok=$((ok+1)); else echo "MODIFIED  $path"; bad=$((bad+1)); fi
done < <(tail -n +2 FILE_LIST.tsv)
echo "verify: $ok OK, $bad MISSING/MODIFIED (public text files only; hash-only groups are documentation, not contents)"
[ "$ok" -gt 0 ] || { echo "verify: no PUBLIC-TEXT entry found in FILE_LIST.tsv"; exit 1; }
[ "$bad" -eq 0 ]
