#!/bin/bash

# Check if the folder path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 </path/to/your/folder> <Collection Name>"
    exit 1
fi

folder_path="$1"
collection_label="$2"

# Check if the folder exists
if [ ! -d "$folder_path" ]; then
    echo "Error: Folder '$folder_path' does not exist."
    exit 1
fi

# Check if the collection label is provided
if [ -z "$collection_label" ]; then
    echo "Error: Collection name cannot be an empty string."
    exit 1
fi

# Display the collection label
echo "Collection Label: $collection_label"

url="http://192.168.1.222:5000/media"

for file in "$folder_path"/*; do
    if [ -f "$file" ]; then

        filename=$(basename "$file")

        echo "uploading $filename"
        mime_type=$(file --mime-type -b "$file")
        
        echo curl -v  -F "media=@${file};type=${mime_type}" -F "collectionLabel=random"  "$url"
        time curl -v  -F "media=@${file};type=${mime_type}" -F "collectionLabel=$collection_label"  "$url"
  
        sleep 1

    fi
done
