#!/bin/sh
set -e
ROJO_CONFIG=$1
# if ROJO_CONFIG = "" then error
if [ -z "$ROJO_CONFIG" ]; then
	echo "ROJO_CONFIG is not set"
	exit 1
fi

DARKLUA_CONFIG=.darklua.json
SOURCEMAP=sourcemap.json
LSP_SETTINGS=".luau-analyze.json"

# get if any of the arguments were "--serve"
is_serve=false
build_dir="build"
for arg in "$@"
do
	if [ "$arg" = "--serve" ]; then
		is_serve=true
		build_dir="serve"
	fi
done

# create build directory
echo "clearing and making $build_dir"
rm -f $SOURCEMAP
rm -rf $build_dir
mkdir -p $build_dir

echo "copying contents to $build_dir"

cp -r "$ROJO_CONFIG" "$build_dir/$ROJO_CONFIG"
cp -r "src" "$build_dir/src"
cp -r "types" "$build_dir/types"
cp -r "lints" "$build_dir/lints"
cp -r "selene.toml" "$build_dir/selene.toml"
cp -r "stylua.toml" "$build_dir/stylua.toml"
cp -r "$LSP_SETTINGS" "$build_dir/$LSP_SETTINGS"

# build sourcemaps
echo "building sourcemaps"
rojo sourcemap "$ROJO_CONFIG" -o "$SOURCEMAP"
rojo sourcemap "$build_dir/$ROJO_CONFIG" -o "$build_dir/$SOURCEMAP"

# process files
echo "running stylua"
stylua "$build_dir/src"

# run darklua
echo "running darklua"
if [ "$is_serve" = true ]; then
	darklua process "src" "$build_dir/src" --config "$DARKLUA_CONFIG" -w & 
else
	darklua process "src" "$build_dir/src" --config "$DARKLUA_CONFIG"
fi

# final compile
if [ "$is_serve" = true ]; then
	echo "running serve"
	rojo serve "$build_dir/$ROJO_CONFIG"
else
	echo "build rbxl"
	cd "$build_dir"
	rojo build "$ROJO_CONFIG" -o "Package.rbxl"
fi