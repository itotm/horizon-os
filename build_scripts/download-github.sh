#!/bin/bash
set -oue pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GITHUB_URL> <DESTINATION_FOLDER>"
    echo "Example (folder): $0 https://github.com/username/reponame/tree/main/path/to/folder ./my-folder"
    echo "Example (archive): $0 https://github.com/username/reponame/raw/main/path/to/archive.zip ./my-folder"
    exit 1
fi

URL=$1
DESTINATION=$2
TEMP_DIR=""

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        echo "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

is_archive_url() {
    local url=$1
    if [[ "$url" =~ \.(zip|tar\.gz|tgz|tar\.bz2|tar\.xz)$ ]] || [[ "$url" =~ /raw/ ]]; then
        return 0
    fi
    return 1
}

get_extension() {
    local url=$1
    if [[ "$url" =~ \.(zip)$ ]]; then
        echo "zip"
    elif [[ "$url" =~ \.(tar\.gz|tgz)$ ]]; then
        echo "tar.gz"
    elif [[ "$url" =~ \.(tar\.bz2)$ ]]; then
        echo "tar.bz2"
    elif [[ "$url" =~ \.(tar\.xz)$ ]]; then
        echo "tar.xz"
    else
        echo "unknown"
    fi
}

extract_archive() {
    local archive_file=$1
    local dest_path=$2
    local extension=$3
    
    echo "Extracting archive to: $dest_path"
    sudo mkdir -p "$dest_path"
    
    case "$extension" in
        zip)
            if ! command -v unzip &> /dev/null; then
                echo "Error: 'unzip' is not installed. Please install it."
                exit 1
            fi
            unzip -q "$archive_file" -d "$dest_path"
            ;;
        tar.gz|tgz)
            tar -xzf "$archive_file" -C "$dest_path" 2>/dev/null
            ;;
        tar.bz2)
            tar -xjf "$archive_file" -C "$dest_path" 2>/dev/null
            ;;
        tar.xz)
            tar -xJf "$archive_file" -C "$dest_path" 2>/dev/null
            ;;
        *)
            echo "Error: Unsupported archive format"
            exit 1
            ;;
    esac
}

download_contents() {
    local api_url=$1
    local dest_path=$2
    
    echo "Creating destination directory (if needed): $dest_path"
    sudo mkdir -p "$dest_path"
    
    local temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' RETURN
    
    curl -s -H "Accept: application/vnd.github.v3+json" "$api_url" > "$temp_file"
    
    if grep -q "\"message\": \"Not Found\"" "$temp_file"; then
        echo "Error: The specified folder was not found in the repository. Please check the URL."
        return 1
    fi
    
    jq -c '.[]' "$temp_file" | while read -r item; do
        local type=$(echo "$item" | jq -r '.type')
        local name=$(echo "$item" | jq -r '.name')
        local path=$(echo "$item" | jq -r '.path')
        local local_filepath="$dest_path/$name"
        
        if [ "$type" == "file" ]; then
            local download_url=$(echo "$item" | jq -r '.download_url')
            echo " -> Downloading file: $path"
            
            local temp_download=$(mktemp)
            curl -s -L "$download_url" -o "$temp_download"
            mv "$temp_download" "$local_filepath"
            chmod +r "$local_filepath"
        elif [ "$type" == "dir" ]; then
            local next_api_url=$(echo "$item" | jq -r '.url')
            echo " -> Exploring directory: $path"
            download_contents "$next_api_url" "$local_filepath"
        fi
    done
}


# Gestione file semplice raw (non archivio)
EXTENSION=$(get_extension "$URL")
if is_archive_url "$URL"; then
    if [ "$EXTENSION" != "unknown" ]; then
        echo "Detected archive URL: $URL"
        TEMP_DIR=$(mktemp -d)
        echo "Created temporary directory: $TEMP_DIR"
        ARCHIVE_NAME=$(basename "$URL")
        TEMP_ARCHIVE="$TEMP_DIR/$ARCHIVE_NAME"
        echo "Downloading archive..."
        curl -s -L -o "$TEMP_ARCHIVE" "$URL"
        extract_archive "$TEMP_ARCHIVE" "$DESTINATION" "$EXTENSION"
        echo "Archive extracted successfully."
    else
        # File raw non compresso
        echo "Detected raw file (not archive): $URL"
        sudo mkdir -p "$DESTINATION"
        FILE_NAME=$(basename "$URL")
        DEST_FILE="$DESTINATION/$FILE_NAME"
        echo "Downloading file..."
        curl -s -L -o "$DEST_FILE" "$URL"
        chmod +r "$DEST_FILE"
        echo "File downloaded successfully."
    fi
else
    if [[ ! "$URL" =~ ^https://github.com/([^/]+)/([^/]+)/tree/([^/]+)/(.*)$ ]]; then
        echo "Invalid GitHub URL. Please ensure it is in the correct format."
        echo "Example: https://github.com/username/reponame/tree/main/path/to/folder"
        exit 1
    fi
    USER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    FOLDER_PATH=$(echo "${BASH_REMATCH[4]}" | sed 's:/*$::')
    API_URL="https://api.github.com/repos/$USER/$REPO/contents/$FOLDER_PATH?ref=$BRANCH"
    echo "Downloading contents from: $URL"
    echo "To destination folder: $DESTINATION"
    if ! command -v jq &> /dev/null; then
        echo "Error: 'jq' is not installed. Please install it to continue."
        echo "On Debian/Ubuntu: sudo apt-get install jq"
        echo "On macOS (with Homebrew): brew install jq"
        exit 1
    fi
    download_contents "$API_URL" "$DESTINATION"
fi

echo "Download complete."
