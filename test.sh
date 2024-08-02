#!/bin/bash
set -eE

# Check if being ran from Dockerfile or user bypass
if [[ -z "$FORCE_CONTINUE" || "$FORCE_CONTINUE" != "true" ]]; then
  echo "====================================="
  echo "   DO NOT RUN THIS SCRIPT DIRECTLY"
  echo "====================================="
  echo "To test and benchmark, build and run the docker image with 'docker build -t 1brc-caffeine . && docker run 1brc-caffeine'"
  printf "\nTo skip this warning, run: 'FORCE_CONTINUE=true ./test.sh"
  exit 1
fi
