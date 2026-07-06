#!/usr/bin/env bash
# TOC graph check — the WoW-addon equivalent of knip's unused-files audit.
#
# For every addon .toc in the repo:
#   1. every file the .toc lists must exist on disk (broken reference)
#   2. every Lua file in the addon must be listed in its .toc (dead file),
#      except vendored Libs/, which load through .xml includes
#   3. every vendored library under Libs/ must be referenced by the .toc
#      (unused dependency)
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

for toc in */*.toc; do
	dir=$(dirname "$toc")

	# File entries: strip comments, blank lines, CR, trailing spaces; \ -> /
	entries=$(grep -vE '^[[:space:]]*(#|$)' "$toc" | tr -d '\r' | tr '\\' '/' | sed 's/[[:space:]]*$//')

	# 1. Broken references. Libs/ entries are packager externals (.pkgmeta),
	# absent from a fresh checkout, so only verify them when Libs/ exists.
	while IFS= read -r entry; do
		[ -z "$entry" ] && continue
		case "$entry" in
		Libs/*) [ -d "$dir/Libs" ] || continue ;;
		esac
		if [ ! -f "$dir/$entry" ]; then
			echo "BROKEN REFERENCE: $toc lists '$entry' but $dir/$entry does not exist"
			fail=1
		fi
	done <<<"$entries"

	# 2. Dead files
	while IFS= read -r lua; do
		rel=${lua#"$dir"/}
		if ! grep -qxF "$rel" <<<"$entries"; then
			echo "DEAD FILE: $lua is not listed in $toc"
			fail=1
		fi
	done < <(find "$dir" -name '*.lua' -not -path "$dir/Libs/*" | sort)

	# 3. Unused vendored libraries
	if [ -d "$dir/Libs" ]; then
		for libdir in "$dir"/Libs/*/; do
			lib=$(basename "$libdir")
			if ! grep -q "Libs/$lib/" <<<"$entries"; then
				echo "UNUSED LIBRARY: $dir/Libs/$lib is not referenced in $toc"
				fail=1
			fi
		done
	fi
done

if [ "$fail" -eq 0 ]; then
	echo "toc check: OK"
fi
exit "$fail"
