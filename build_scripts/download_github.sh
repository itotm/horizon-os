#!/bin/bash
set -ouex pipefail

# Exit immediately if a command exits with a non-zero status.
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GITHUB_FOLDER_URL> <DESTINATION_FOLDER>"
    echo "Example: $0 https://github.com/username/reponame/tree/main/path/to/folder ./my-folder"
    exit 1
fi

URL=$1
DESTINATION=$2

# CORRECTED REGEX: Removed the erroneous space from the first capture group.
if [[ ! "$URL" =~ ^https://github.com/([^/]+)/([^/]+)/tree/([^/]+)/(.*)$ ]]; then
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

    echo "Creating destination directory (if needed): $dest_path"
    sudo mkdir -p "$dest_path"

    # Use a temporary file to avoid issues with pipes in loops
    local temp_file=$(mktemp)
    # Ensure temp file is cleaned up on script exit
    trap 'rm -f "$temp_file"' EXIT

    curl -s -H "Accept: application/vnd.github.v3+json" "$api_url" > "$temp_file"

    if grep -q "\"message\": \"Not Found\"" "$temp_file"; then
        echo "Error: The specified folder was not found in the repository. Please check the URL."
        exit 1
    fi

    # Process files and directories
    jq -c '.[]' "$temp_file" | while read -r item; do
        local type=$(echo "$item" | jq -r '.type')
        local name=$(echo "$item" | jq -r '.name')
        local path=$(echo "$item" | jq -r '.path')
        local local_filepath="$dest_path/$name"

        if [ "$type" == "file" ]; then
            local download_url=$(echo "$item" | jq -r '.download_url')
            echo " -> Downloading file: $path"
            local temp_download=$(mktemp)
            trap 'rm -f "$temp_download"' EXIT
            curl -s -L "$download_url" -o "$temp_download"
            sudo mv "$temp_download" "$local_filepath"
        elif [ "$type" == "dir" ]; then
            local next_api_url=$(echo "$item" | jq -r '.url')
            echo " -> Exploring directory: $path"
            # Recursive call
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
