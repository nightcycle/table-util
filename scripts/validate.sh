#!/bin/sh
set -e
ROJO_CONFIG=$1
# if ROJO_CONFIG = "" then error
if [ -z "$ROJO_CONFIG" ]; then
	echo "ROJO_CONFIG is not set"
	exit 1
fi
sh scripts/download-types.sh
sh scripts/build.sh "$ROJO_CONFIG"
cd "build"
luau-lsp analyze \
	--sourcemap="sourcemap.json" \
	--ignore="**/Packages/**" \
	--ignore="Packages/**" \
	--ignore="*.spec.luau" \
	--settings=".luau-analyze.json" \
	--definitions="types/globalTypes.d.lua" \
	"src"
selene src