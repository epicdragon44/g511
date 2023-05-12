#!/bin/bash

# Get the directory where the script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Initialize line count
total=0

# Find all .ml and .mli files, excluding those within _build directories
while IFS= read -r -d '' file; do
    if [[ $file == *_build* ]]; then
        # Ignore files within _build directories
        continue
    fi

    # Count lines in each file
    lines=$(wc -l < "$file")
    total=$((total + lines))
done < <(find "$DIR" -type f \( -name "*.ml" -o -name "*.mli" \) -print0)

# Print total line count
echo "Total lines of code: $total"
