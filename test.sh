#!/bin/bash
set -eE

# Check if being run from Dockerfile or user bypass
if [[ -z "$FORCE_CONTINUE" || "$FORCE_CONTINUE" != "true" ]]; then
  echo "====================================="
  echo "   DO NOT RUN THIS SCRIPT DIRECTLY"
  echo "====================================="
  echo "To test and benchmark, build and run the docker image with 'docker build -t 1brc-caffeine . && docker run 1brc-caffeine'"
  printf "\nTo skip this warning, run: 'FORCE_CONTINUE=true ./test.sh'\n"
  exit 1
fi

echo "Running 1brc tests and benchmarks..."

# Check existence of required files
if [[ ! -f measurements.txt ]]; then
  echo "Error: measurements.txt not found"
  echo "Build and run 'java/CreateMeasurements.java' with 1000000 to generate measurements.txt"
  exit 1
fi

if [[ ! -d data ]]; then
  echo "Error: data directory not found"
  exit 1
fi

if [[ ! -f 1brc ]]; then
  echo "Error: 1brc binary not found"
  echo "Build it with 'go build -o 1brc .'"
  exit 1
fi

if [[ ! -f 1brc.test ]]; then
  echo "Error: 1brc.test binary not found"
  echo "Build it with 'go test -c -o 1brc_test .'"
  exit 1
fi

# To improvve diffing by replacing , with \n
preprocess_output() {
  sed 's/,/\n/g' "$1"
}

# Comparing outputs
compare_output() {
  local input_file=$1
  local expected_output_file=$2
  local actual_output_file="actual_output.tmp"

  ./1brc "$input_file" >"$actual_output_file"

  if diff "$expected_output_file" "$actual_output_file" >/dev/null; then
    echo "Test passed for $input_file"
  else
    echo "Test failed for $input_file"
    echo "Diff:"
    diff <(preprocess_output "$expected_output_file") <(preprocess_output "$actual_output_file")
    rm -f "$actual_output_file"
    exit 1
  fi
  rm -f "$actual_output_file"
}

# Run tests
echo "Testing binary..."
for input_file in data/*.txt; do
  output_file="${input_file%.txt}.out"
  if [[ -f "$output_file" ]]; then
    compare_output "$input_file" "$output_file"
  else
    echo "Warning: Expected output file $output_file not found. Skipping test for $input_file."
  fi
done

# Run benchmarking
echo "Running benchmarks with 1brc.test..."
./1brc.test -test.bench .
