#!/usr/bin/env bash
set -uxo pipefail

run_folder() {
    local folder=$1
    if [ -d "$folder" ]; then
        folder=$(basename "$folder")
        cd "$folder" || exit
        if [ -x "./run-kontrol.sh" ]; then
            echo "Running Kontrol in $folder."
            ./run-kontrol.sh || true
        else
            echo "No executable run-kontrol.sh found in $folder."
        fi
        cd ..
    fi
}

clean_folder() {
    local folder=$1
    if [ -d "$folder" ]; then
        folder=$(basename "$folder")
        cd "$folder" || exit
        if [ -n "${FOUNDRY_PROFILE+x}" ]; then
            echo "Found Foundry profile $FOUNDRY_PROFILE"
            kontrol clean
            unset FOUNDRY_PROFILE
        fi
        if [ "$folder" = "3-proof-debugging" ]; then
             FOUNDRY_PROFILE=lemmas kontrol clean
             unset FOUNDRY_PROFILE
        fi
        kontrol clean
        echo "Cleaned $folder"
        cd ..
    fi
}

error_message() {
    echo "Provide no arguments to execute all folders."
    echo "Provide one folder name to execute it individually."
    echo "Provide 'clean' to clean all folders"
    echo "Provide 'clean \$folder' to clean \$folder"
    exit 1
}

if [ "$#" -eq 0 ]; then
    for folder in ./*; do
        run_folder "$folder"
    done
elif [ "$#" -eq 1 ]; then
    if [ -d "$1" ]; then
        run_folder "$1"
    elif [ "$1" = "clean" ]; then
         for folder in ./*; do
             clean_folder "$folder"
         done
    else
        echo "$1 is not a folder nor 'clean'!"
        exit 1
    fi
elif [ "$#" -eq 2 ]; then
     if [ "$1" = "clean" ] && [ -d "$2" ]; then
        clean_folder "$2"
     else
         error_message
     fi
else
    error_message
fi