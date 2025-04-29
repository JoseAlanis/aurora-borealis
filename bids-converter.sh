#!/bin/bash

# Exit if any command fails
set -e

# Usage function
usage() {
  echo "Usage: $0 <volume_path> <subjects> <sessions> [--overwrite true|false]"
  echo ""
  echo "Arguments:"
  echo "  volume_path      Absolute path on the host machine to mount into the container"
  echo "  subjects         Space-separated list of subject IDs (e.g., \"01 02 03\")"
  echo "  sessions         Space-separated list of session IDs (e.g., \"001 002\")"
  echo ""
  echo "Optional:"
  echo "  --overwrite      Whether to force overwriting output (true/false). Default: false."
  echo "  --help           Show this help message and exit."
  exit 1
}

# Check for help early
if [[ "$1" == "--help" ]]; then
  usage
fi

# Check if at least 3 arguments are passed
if [ "$#" -lt 3 ]; then
  usage
fi

# Parse required arguments
volume_path="$1"
shift
subjects=($1)
shift
sessions=($1)
shift

# Default value
overwrite=false

# Optional arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --overwrite)
      overwrite="$2"
      shift 2
      ;;
    --help)
      usage
      ;;
    *)
      echo "Unknown parameter passed: $1"
      usage
      ;;
  esac
done

# Main loop
for subject in "${subjects[@]}"; do
  for session in "${sessions[@]}"; do
    echo ""
    echo "----------------------------------------"
    echo "Processing subject $subject, session $session"

    output_dir="${volume_path}/bidsdata/sub-${subject}/ses-${session}"

    # Check if output directory already exists
    if [[ -d "$output_dir" && "$overwrite" != "true" ]]; then
      echo "⚠️  Warning: Output directory already exists for subject ${subject}, session ${session}:"
      echo "    ${output_dir}"
      echo "  (use --overwrite true to force overwriting)"
      echo "  --> Skipping..."
      continue
    fi

    # Build Docker command
    docker_command=(
      sudo docker run --rm -it
      -v "${volume_path}":/base
      nipy/heudiconv:latest
      -d /base/bidsdata/sourcedata/${subject}/${session}/*
      -o /base/bidsdata/
      -f /base/heuristic.py
      -s ${subject}
      -ss ${session}
      -c dcm2niix
      -b
    )

    if [[ "$overwrite" == "true" ]]; then
      docker_command+=(--overwrite)
    fi

    # Run the Docker command
    "${docker_command[@]}"
  done
done

echo ""
echo "✅ All requested subjects and sessions processed."
