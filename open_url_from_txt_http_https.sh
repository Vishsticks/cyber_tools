#!/bin/bash

# Specify the file containing the list of domain names
file="urls.txt"

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "File does not exist."
    exit 1
fi

# Function to open a URL with a delay
open_url() {
  # Use xdg-open for Linux or open for macOS to open the URL in the default browser
  xdg-open "$1" 2>/dev/null || open "$1" 2>/dev/null
  
  # Sleep for a bit to avoid opening too many at once
  sleep 2
}

# Read each line in the file
while IFS= read -r line
do
  # Skip empty lines
  if [ -z "$line" ]; then
    continue
  fi
  
  # Try opening with https first
  https_url="https://$line"
  echo "Trying $https_url"
  open_url "$https_url"
  
  # Then try with http
  http_url="http://$line"
  echo "Trying $http_url"
  open_url "$http_url"
done < "$file"

