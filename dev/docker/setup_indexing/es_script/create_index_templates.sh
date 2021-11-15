#!/usr/bin/env sh

# Setup script for elasticsearch. This script MUST be run before any indexing.
# This script can be executed several times on the same elasticsearch cluster (even if no changes will happen after the
# first time).
# The first argument is the URL to the cluster. It must have a HTTP(s) scheme.

if [[ -z "$1" ]] ; then
    echo 'ES URL is missing'
    exit 1
fi

es_cluster_url=$1
prefix=$2

check_execution()
{
  name=$1
  result=$2
  echo
  if [[ $result == 0 ]] ; then
    echo "Template ($name) successfully set"
  else
    echo "Template creation failed ($name)"
  fi
}

echo "Creating index templates..."

# Set the index template for flights data
template="${prefix}flight"
cat << EOF | curl -X PUT "$es_cluster_url/_template/${template}" -H "Content-type: application/json" -d @-
{
  "index_patterns": [
    "flight*"
  ],
  "settings": {
    "number_of_shards": 5
  },
  "mappings": {
    "properties": {
      "flight_date": {
        "type": "date"
      },
      "full_name": {
        "type": "text"
      },
      "flight_type": {
        "type": "keyword",
        "ignore_above": 256
      },
      "distance": {
        "type": "float"
      },
      "url": {
        "type": "text"
      },
      "publication_date": {
        "type": "date"
      }
    }
  }
}
EOF
check_execution $template $?