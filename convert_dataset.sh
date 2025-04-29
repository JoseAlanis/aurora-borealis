#!/bin/bash

# Define your list of subjects and sessions
subjects=("01")               # Add more as needed
sessions=("001" "002" "003")        # Add more as needed

# Loop through subjects and sessions
for subject in "${subjects[@]}"; do
  for session in "${sessions[@]}"; do
    echo "Processing subject $subject, session $session"
    
    sudo docker run --rm -it \
      -v /media/josealanis/xpro10-2025/neuromod/borealis/:/base \
      nipy/heudiconv:latest \
      -d /base/bidsdata/sourcedata/{subject}/{session}/A/* \
      -o /base/bidsdata/ \
      -f /base/heuristic.py \
      -s ${subject} \
      -ss ${session} \
      -c dcm2niix \
      -b \
      --overwrite
  done
done