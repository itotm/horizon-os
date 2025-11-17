#!/bin/bash

# set -e: Exit immediately if a command exits with a non-zero status.
# set -u: Treat unset variables as an error when substituting.
set -eu

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GITHUB_FOLDER_URL> <DESTINATION_FOLDER>"
    echo "Example: $0 https://github.com/username/reponame/tree/main/path/to/folder ./my-folder"
    exit 1
fi

URL=$1
DESTINATION=$2

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

    # Create a temporary file for the API response.
    # It will be cleaned up automatically when the function returns.
    local temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' RETURN

    curl -s -H "Accept: application/vnd.github.v3+json" "$api_url" > "$temp_file"

    if grep -q "\"message\": \"Not Found\"" "$temp_file"; then
        echo "Error: The specified folder was not found in the repository. Please check the URL."
        return 1
    fi

    # Read the JSON response and process each item.
    jq -c '.[]' "$temp_file" | while read -r item; do
        local type=$(echo "$item" | jq -r '.type')
        local name=$(echo "$item" | jq -r '.name')
        local path=$(echo "$item" | jq -r '.path')
        local local_filepath="$dest_path/$name"

        if [ "$type" == "file" ]; then
            local download_url=$(echo "$item" | jq -r '.download_url')
            echo " -> Downloading file: $path"
            
            # Use a temporary file for the download to handle permissions safely.
            local temp_download=$(mktemp)
            curl -s -L "$download_url" -o "$temp_download"
            mv "$temp_download" "$local_filepath"
            chmod +r "$local_filepath"
            # No need to trap/rm here, mv cleans it up. If mv fails, set -e stops the script.

        elif [ "$type" == "dir" ]; then
            local next_api_url=$(echo "$item" | jq -r '.url')
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
