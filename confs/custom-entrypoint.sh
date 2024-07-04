#!/bin/sh
# Run your gen-conf script
`apk add yq &> /dev/null`
# Check if yq is installed
if ! command -v yq &> /dev/null
then
    echo "yq is not installed. Please install it to parse YAML files."
    exit 1
fi
# Check if the required files exist
if [ ! -f "./config.yml" ] || [ ! -f "./sample.xconf" ]; then
    echo "Missing config.yml or sample.conf file."
    exit 1
fi

# Read the number of sites from config.yml
num_sites=$(yq e '.sites | length' config.yml)

# Loop through each site in the config
# Get the number of sites
num_sites=$(yq e '.sites | length' config.yml)

i=0
while [ $i -lt $num_sites ]
do
    # Extract values from config.yml
    map=$(yq e ".sites[$i].map" config.yml)
    to=$(yq e ".sites[$i].to" config.yml)
    php=$(yq e ".sites[$i].php" config.yml)

    # Create a new configuration file
    output_file="${map}.conf"

    # Use sed to replace placeholders in sample.conf and create new file
    sed -e "s|{{MAP}}|$map|g" \
        -e "s|{{TO}}|$to|g" \
        -e "s|{{PHP}}|$php|g" \
        sample.xconf > "/etc/nginx/conf.d/$output_file"

    echo "Generated $output_file"

    i=$((i + 1))
done
`nginx -s reload`
echo "Configuration files generation and loaded."

# Start Nginx
exec nginx -g 'daemon off;'