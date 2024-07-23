#!/bin/bash

set -e

# Create ILM Policy -----------------------------------------------------------> FUNZIONA
curl -X PUT '10.0.2.1:9200/_ilm/policy/ft-transcendence_policy' \
     -u elastic:elasticpwd \
     -H 'Content-Type: application/json' \
     -d ' 
{
    "policy": {
        "_meta": {
            "description": "used for ft-transcendece logs",
            "project": {
                "name": "ft-transcendence"
            }
        },
        "phases": {
            "warm": {
                "min_age": "1d",
                "actions": {
                    "forcemerge": {
                        "max_num_segments": 1
                    }
                }
            },
            "delete": {
                "min_age": "7d",
                "actions": {
                    "delete": {}
                }
            }
        }
    }
}'

# Create DataStream -----------------------------------------------------------> DA SISTEMARE
curl -X PUT '10.0.2.1:9200/_ilm/policy/ft-transcendence_policy' \
     -u elastic:elasticpwd \
     -H 'Content-Type: application/json' \
     -d ' 
        {
            "index_patterns": ["logs-*"],
            "data_stream": {},
            "lifecycle": {
                "name": "ft-transcendence_policy"
            },
            "settings": {
                "number_of_shards": 1
            },
            "mappings": {
                "properties": {
                    "@timestamp": {
                        "type": "date"
                    }
                }
            }
        }'

