#!/bin/bash

# Define the old and new base paths
if [[ $PWD =~ $re ]]; then LNUM=${BASH_REMATCH}; fi
old_base="/tmp/ddf"
re="L[0-9][0-9][0-9][0-9][0-9][0-9]"
re_subband="([^.]+)"
if [[ $PWD =~ $re ]]; then OBSERVATION=${BASH_REMATCH}; fi

# Loop over all symlinks in the current directory
for symlink in SOLSDIR/L*.ms/*.npz; do
    if [ -L "$symlink" ]; then
        target=$(readlink "$symlink")
        if [[ "$target" == $old_base* ]]; then
            LNUM=$OBSERVATION
            new_base="/project/wfedfn/Data/${LNUM}/ddf/"
            new_target="${target/$old_base/$new_base}"
            match="ddf" 
            echo "Updating symlink: $symlink"
            rm "$symlink"
            ln -s "$new_target" "$symlink"
            echo "Symlink updated: $symlink -> $new_target"
        fi
        echo "Skipping $symlink: Not a valid symlink"
    fi
done

