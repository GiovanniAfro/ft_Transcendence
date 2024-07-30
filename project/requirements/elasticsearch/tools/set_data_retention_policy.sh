#!/bin/bash

set -eu

# Create ILM Policy ----------------------------------------------------------->
curl -X PUT '10.0.2.1:9200/_ilm/policy/ft-transcendence-policy' \
     -u elastic:elasticpwd \
     -H 'Content-Type: application/json' \
     -d '
{
  "policy": {
    "_meta": {
      "description": "used for ft-transcendence logs",
      "project": {
        "name": "ft-transcendence"
      }
    },
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": {
            "priority": 100
          }
        }
      },
      "delete": {
        "min_age": "1h",
        "actions": {
          "delete": {
            "delete_searchable_snapshot": true
          }
        }
      }
    }
  }
}'

# Create a Index Template ----------------------------------------------------->
curl -X PUT "localhost:9200/_index_template/ft-transcendence-logs?pretty" \
     -u elastic:elasticpwd \
     -H 'Content-Type: application/json' \
     -d '
{
  "index_patterns": [
    "logs-*-*"
  ],
  "template": {
    "settings": {
      "index": {
        "lifecycle": {
          "name": "ft-transcendence-policy"
        }
      }
    }
  },
  "composed_of": [
    "logs@mappings",
    "logs@settings",
    "ecs@mappings"
  ],
  "priority": 100000,
  "data_stream": {
    "hidden": false,
    "allow_custom_routing": false
  },
  "allow_auto_create": true
}'
