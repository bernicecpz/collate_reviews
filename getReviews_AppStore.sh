#!/bin/bash

#TODO: Automate installation of jq

#Define all the files to refer to
app_store_country_code="countryCodes.txt"

results_dir="reviewResults"
minify_dir="minifyResults"

if [ -d "reviewResults" ]; then
    rm -r "$results_dir"
    mkdir -p "$results_dir"
else
    mkdir -p "$results_dir"
fi


if [ -d "minifyResults" ]; then
  rm -r "$minify_dir"
  mkdir -p "$minify_dir"
else
  mkdir -p "$minify_dir"
fi


#Format of RSS feed file link path parameters
#Syntax: https://itunes.apple.com/<country_code>/rss/customerreviews/id=<app_id>/json
#Example: https://itunes.apple.com/gb/rss/customerreviews/id=317212648/json
#Note: You can add sortBy=mostRecent/ before the json if you want to sort by most recent
#app_id can be retrieve by visiting the AppStore on web to get its parameter
#Using YouTube as an example: https://apps.apple.com/sg/app/youtube-watch-listen-stream/id544007664
#its app_id is 544007664
base_url="https://itunes.apple.com/"
rss_review="/rss/customerreviews/"
app_id="id=<app_id>"
format_type="/json"
all_country_names=$(cat countryCodes.txt | cut -d : -f 2)


#Will retrieve the RSS feed of reviews from each country
#Then store inside file
IFS=$'\n'
echo "Downloading all reviews from each country "

for country_name in $all_country_names
do
    result_filename="$results_dir/reviews-$country_name.json"
    
    country_code=$(cat countryCodes.txt | grep "$country_name$" | cut -d : -f 1)

    url_to_curl="$base_url$country_code$rss_review$app_id$format_type"

    reviews_results=$(curl --silent "$url_to_curl")

    #Check if got entry keyword in JSON
    check_entry=$(echo "$reviews_results" | grep "entry")

    #Only output into file if got reviews from that country
    if ! [ -z "$check_entry" ]; then

        echo "$reviews_results" > "$result_filename"
      
        #Minify to ensure no spaces to access keywords via jq
        minify_filename="$minify_dir/reviews-$country_name.json"        
        get_content=$(cat "$result_filename")
        minify_content=$(echo "$get_content" | tr '\r\n' ' ' | jq -c)
        echo "$minify_content" > $minify_filename

    fi
done
