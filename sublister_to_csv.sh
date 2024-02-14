#!/bin/bash

# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain="$1"
output_file="${domain}_subdomains_details.csv"

# Run Sublist3r and save the output to a temporary file
sublist3r -d "$domain" -o temp.txt

# Check if Sublist3r found any subdomains
if [ ! -s temp.txt ]; then
    echo "No subdomains found for $domain."
    rm temp.txt
    exit 1
fi

# Prepare the CSV file
echo "Subdomain,IP Address,HTTP Status,WAF Detected" > "$output_file"

# Read each subdomain and perform checks
while IFS= read -r subdomain; do
    echo "Processing: $subdomain"
    
    # Resolve the IP address(es)
    ip=$(dig +short "$subdomain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    
    # Use curl to get the HTTP status code with a 30-second timeout
    http_status=$(curl -I -m 30 -s -o /dev/null -w "%{http_code}" "$subdomain")
    
    # Check for WAF with wafw00f
    waf_output=$(wafw00f "$subdomain" | grep "is behind" | sed -e 's/.*is behind a //')
    waf_detected=$(echo $waf_output | grep -v "No WAF detected" | cut -d ' ' -f 1)
    
    # If wafw00f didn't detect a WAF or the output was not as expected, leave WAF info blank
    if [ -z "$waf_detected" ]; then
        waf_info=""
    else
        waf_info="$waf_detected"
    fi

    # Write the results to the CSV file
    echo "$subdomain,$ip,$http_status,\"$waf_info\"" >> "$output_file"
    
    # Print a message in the terminal after each website is processed
    echo "Completed: $subdomain"
done < temp.txt

# Remove the temporary file
rm temp.txt

echo "Process completed. Check the '$output_file' for detailed information."
