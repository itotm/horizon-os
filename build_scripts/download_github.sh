#!/bin/bash
set -ouex pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GITHUB_FOLDER_URL> <DESTINATION_FOLDER>"
    echo "Example: $0 https://github.com/username/reponame/tree/main/path/to/folder ./my-folder"
    exit 1
fi

URL=$1
DESTINATION=$2

if [[ ! "$URL" =~ ^https://github.com/([^/]+ )/([^/]+)/tree/([^/]+)/(.*)$ ]]; then
    echo "Invalid GitHub URL. Please ensure it is in the correct format."
    echo "Example: https://github.com/username/reponame/tree/main/path/to/folder"
    exit 1
fi

USER="${BASH_REMATCH[1]}"
REPO="${BASH_REMATCH[2]}"
BRANCH="${BASH_REMATCH[3]}"
FOLDER_PATH=$(echo "${BASH_REMATCH[4]}" | sed 's:/*$::' )

API_URL="https://api.github.com/repos/$USER/$REPO/contents/$FOLDER_PATH?ref=$BRANCH"

echo "Downloading contents from: $URL"
echo "To destination folder: $DESTINATION"

download_contents( ) {
    local api_url=$1
    local dest_path=$2

    mkdir -p "$dest_path"

    curl -s -H "Accept: application/vnd.github.v3+json" "$api_url" | jq -c '.[]' | while read -r item; do
        local type=$(echo "$item" | jq -r '.type')
        local download_url=$(echo "$item" | jq -r '.download_url')
        local name=$(echo "$item" | jq -r '.name')
        local path=$(echo "$item" | jq -r '.path')
        local next_api_url=$(echo "$item" | jq -r '.url')
        local local_filepath="$dest_path/$name"

        if [ "$type" == "file" ]; then
            echo " -> Downloading file: $path"
            curl -s -L "$download_url" -o "$local_filepath"
        elif [ "$type" == "dir" ]; then
            echo " -> Exploring directory: $path"
            download_contents "$next_api_url" "$local_filepath"
        fi
    done
}

if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it to continue."
    echo "On Debian/Ubuntu: sudo apt-get install jq"
    echo "On macOS (with Homebrew): brew install jq"
    exit 1
fi

download_contents "$API_URL" "$DESTINATION"

echo "Download complete."
