#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR" || exit

for dir in "$SCRIPT_DIR"/*/
do
    dir=${dir%*/}      # remove the trailing "/"
    currdir="${dir##*/}"    # print everything after the final "/"
    PUBSPEC="$SCRIPT_DIR/$currdir/pubspec.yaml"
    if test -f "$PUBSPEC"; then
        echo "$currdir is a flutter project"
        pushd "$SCRIPT_DIR/$currdir" || exit
        flutter clean
        
        popd || exit
    else
        echo "$currdir is not a flutter project"
    fi
    
done

popd || exit
