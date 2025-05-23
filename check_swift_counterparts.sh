#!/bin/bash

# Find all .m files and check for .swift counterparts
find "/Users/tmoore/Desktop/Refactoring PaleoRose/PaleoRose" -name "*.m" | sort | while read -r objc_file; do
    # Get the base filename without extension
    base_name="${objc_file%.*}"
    swift_file="${base_name}.swift"
    
    if [ -f "$swift_file" ]; then
        echo "✅ $objc_file has a Swift counterpart"
    else
        echo "❌ $objc_file is MISSING Swift counterpart"
    fi
done
