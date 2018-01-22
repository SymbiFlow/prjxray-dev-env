#!/bin/bash -x

if [ $# -lt 1 ]; then
  >&2 echo "Usage: stream_url.sh <URL>"
  exit 1;
fi

FETCH_URL="$1"
FETCH_HEADER=

if [ "$(expr "$1" : '\([^:]*\):')" == "gs" ] ; then
  if [ -e /staging/access_token ]; then
    GCP_ACCESS_TOKEN="$(cat /staging/access_token | jq -r .access_token)"
  fi

  if [ -z "${GCP_ACCESS_TOKEN}" ]; then
    >&2 echo "Google Cloud Storage URL requested but no access token available"
    >&2 echo "Did you forget to set GCP_ACCESS_TOKEN?"
    exit 1
  fi

  GCS_BUCKET="$(expr "$1" : 'gs://\([^/]*\)/')"
  GCS_OBJECT="$(expr "$1" : 'gs://[^/]*/\(.*\)')"
  FETCH_URL="https://www.googleapis.com/storage/v1/b/${GCS_BUCKET}/o/${GCS_OBJECT}?alt=media"
  FETCH_HEADER="Authorization: Bearer ${GCP_ACCESS_TOKEN}"
fi

curl ${FETCH_HEADER:+-H} "${FETCH_HEADER}" "${FETCH_URL}"

