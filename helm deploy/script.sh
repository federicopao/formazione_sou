#! /bin/bash

HAS_LIVENESS_PROBE=$(jq '.spec.template.spec.containers[] | select(has("livenessProbe")) | .name' deployment.json)

HAS_READINESS_PROBE=$(jq '.spec.template.spec.containers[] | select(has("readinessProbe")) | .name' deployment.json)

HAS_LIMITS=$(jq '.spec.template.spec.containers[] | select(has("limits")) | .name' deployment.json)

HAS_REQUESTS=$(jq '.spec.template.spec.containers[] | select(has("requests")) | .name' deployment.json)
if [ -z "$HAS_LIVENESS_PROBE" ] || [ -z "$HAS_READINESS_PROBE" ] || [ -z "$HAS_LIMITS" ] || [ -z "$HAS_REQUESTS" ]; then
  echo "ERROR"
else
  echo "SUCCESS"
fi
