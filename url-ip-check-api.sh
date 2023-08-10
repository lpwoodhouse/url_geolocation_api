#!/bin/bash

# Set text colors
GREY='\033[0;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the URL as input
read -p "Enter URL: " url

# Resolve IP addresses
ip_addresses=($(dig +short "$url"))

if [ ${#ip_addresses[@]} -eq 0 ]; then
    echo -e "\n${RED}Could not resolve IP addresses for the provided URL.${NC}"
    exit 1
fi

# Display count of resolved IP addresses
if [ ${#ip_addresses[@]} -eq 1 ]; then
    echo -e "\n${GREEN}$url${GREY} resolves to ${GREEN}${#ip_addresses[@]}${GREY} address${NC}"
else
    echo -e "\n${GREEN}$url${GREY} resolves to ${GREEN}${#ip_addresses[@]}${GREY} addresses${NC}"
fi

# Get API token
token=<enter API token from api.findip.net here>

# Display formatted output for each IP address
for index in "${!ip_addresses[@]}"; do
    ip_address="${ip_addresses[$index]}"
    response=$(curl -s "https://api.findip.net/$ip_address/?token=$token")

    # Check if the response contains an error
    if [[ $response == *"error"* ]]; then
        echo -e "\n${GREY}Skipping Address $((index + 1)) (${RED}$ip_address${NC})"
        continue
    fi

    # Define an array of keys for JSON extraction
    keys=("city.names.en" "continent.names.en" "country.names.en" "country.iso_code" "location.latitude" "location.longitude" "location.time_zone" "postal.code" "subdivisions[0].names.en" "subdivisions[1].names.en" "traits.isp" "traits.organization" "traits.user_type")

    # Extract values from the response using jq
    declare -A extracted_values
    for key in "${keys[@]}"; do
        extracted_values["$key"]=$(echo "$response" | jq -r ".$key")
    done

    # Display formatted output
    echo -e "\n${GREY}Details for Address $((index + 1)) (${RED}$ip_address${NC})"
    for key in "${keys[@]}"; do
        value="${extracted_values[$key]}"
        echo -e "${GREY}${key^^}: ${GREEN}$value${NC}"
    done
done
