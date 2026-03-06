#!/bin/bash

# Check if a file was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <video_file>"
    exit 1
fi

INPUT_FILE="$1"
MAX_SIZE_MB=185 # Slightly less than 190MB for safety buffer
OUTPUT_PATTERN="${INPUT_FILE%.*}_part_%03d.${INPUT_FILE##*.}"

# Get file size in bytes
FILE_SIZE=$(stat -c%s "$INPUT_FILE")
FILE_SIZE_MB=$(echo "$FILE_SIZE / 1024 / 1024" | bc)

# If file is already smaller than the limit, exit
if [ "$FILE_SIZE_MB" -le "$MAX_SIZE_MB" ]; then
    echo "File is already smaller than ${MAX_SIZE_MB}MB. No splitting needed."
    exit 0
fi

# Get total duration in seconds
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

# Calculate target segment duration
# Segment duration = (Max size / Total size) * Total duration
SEGMENT_DURATION=$(echo "scale=2; ($MAX_SIZE_MB / $FILE_SIZE_MB) * $DURATION" | bc)

echo "Splitting '$INPUT_FILE' into segments of approximately $SEGMENT_DURATION seconds..."

ffmpeg -i "$INPUT_FILE" -c copy -map 0 -f segment -segment_time "$SEGMENT_DURATION" -reset_timestamps 1 "$OUTPUT_PATTERN"

echo "Splitting complete."
