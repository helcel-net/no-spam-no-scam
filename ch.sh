#!/bin/bash

# URL of the local.ch page
local_ch_url="https://www.local.ch/en"

# Fetch the local.ch page and extract the buildId
build_id=$(curl -s "$local_ch_url" | grep -oP '"buildId":"\K[^"]+')

# Base URL for the JSON file
url="https://www.local.ch/_next/data/$build_id/en/verified-telemarketing-numbers.json"

initial_data=$(curl -s "$url")
total=$(echo "$initial_data" | jq -r '.pageProps.total')


# Calculate the number of pages (each page contains 100 numbers)
pages=$(( (total + 99) / 100 ))

# Initialize an empty array to hold all the numbers
all_numbers=$(echo "$initial_data" | jq -r '.pageProps.telemarketingNumbers[][0]')

# Loop through each page and fetch the numbers
for (( page=1; page<=pages; page++ ))
do
    # Fetch the JSON data for the current page
    page_data=$(curl -s "${url}?page=${page}")
    # Extract the numbers and add them to the array
    numbers=$(echo "$page_data" | jq -r '.pageProps.telemarketingNumbers[][0]')
    all_numbers="${all_numbers}\n${numbers}"
done

# Prepend each number with + and join them with commas
formatted_numbers=$(echo "$all_numbers" | sed 's/^/+/g' | paste -sd ',' -)

# Output the formatted numbers
echo "$formatted_numbers" > ch.txt
