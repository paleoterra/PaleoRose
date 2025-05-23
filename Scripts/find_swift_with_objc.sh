#!/bin/bash

# Find all Swift files that have an Objective-C counterpart
find "${SRCROOT}" -name "*.swift" | while read -r swift_file; do
    # Get the base filename without extension
    base_name="${swift_file%.*}"
    
    # Check if there's a corresponding .m file
    if [ -f "${base_name}.m" ]; then
        # Print the relative path from SRCROOT
        echo "${swift_file#$SRCROOT/}"
    fi
done > "${SRCROOT}/swift_with_objc.txt"

echo "Created swift_with_objc.txt with list of Swift files that have Objective-C counterparts"
