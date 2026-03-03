#!/bin/bash
# DevLingo Screenshot Capture Script
# Captures screenshots in English, Portuguese, and Spanish

set -e

PROJECT_DIR="/Users/joaoflores/Documents/GambitStudio/DevLingoRepo/DevLingo"
OUTPUT_DIR="$PROJECT_DIR/Screenshots"
DEVICE="iPhone 16 Pro Max"
SCHEME="DevLingoUITests"
TEST_METHOD="ScreenshotTests/testCaptureAllScreens"

# Languages: code -> folder name
declare -A LANGS
LANGS[en]="en-US"
LANGS[pt-BR]="pt-BR"
LANGS[es]="es-ES"

declare -A REGIONS
REGIONS[en]="US"
REGIONS[pt-BR]="BR"
REGIONS[es]="ES"

# Clean output dir
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for lang in en pt-BR es; do
    folder="${LANGS[$lang]}"
    region="${REGIONS[$lang]}"
    echo ""
    echo "================================================"
    echo "  Capturing screenshots for: $folder"
    echo "================================================"
    echo ""

    mkdir -p "$OUTPUT_DIR/$folder"

    DERIVED_DATA="$PROJECT_DIR/DerivedDataScreenshots"
    rm -rf "$DERIVED_DATA"

    xcodebuild test \
        -project "$PROJECT_DIR/DevLingo.xcodeproj" \
        -scheme "DevLingoUITests" \
        -destination "platform=iOS Simulator,name=$DEVICE" \
        -testLanguage "$lang" \
        -testRegion "$region" \
        -only-testing:"DevLingoUITests/$TEST_METHOD" \
        -derivedDataPath "$DERIVED_DATA" \
        2>&1 | grep -E "Test Case|screenshot|BUILD|error:|FAIL" || true

    # Find and copy screenshots from test results
    RESULTS_DIR=$(find "$DERIVED_DATA" -name "*.xcresult" -type d 2>/dev/null | head -1)

    if [ -n "$RESULTS_DIR" ]; then
        echo "Found results at: $RESULTS_DIR"

        # Extract screenshots using xcresulttool
        # List all attachments
        xcrun xcresulttool get --path "$RESULTS_DIR" --format json 2>/dev/null > /tmp/results.json || true

        # Use xcparse or manual extraction
        # Find PNG files in the result bundle
        find "$RESULTS_DIR" -name "*.png" -type f 2>/dev/null | while read png; do
            filename=$(basename "$png")
            cp "$png" "$OUTPUT_DIR/$folder/$filename"
            echo "  Copied: $filename"
        done

        # Also try extracting from Attachments
        ATTACHMENTS=$(find "$DERIVED_DATA" -path "*/Attachments/*.png" -type f 2>/dev/null)
        if [ -n "$ATTACHMENTS" ]; then
            echo "$ATTACHMENTS" | while read png; do
                filename=$(basename "$png")
                cp "$png" "$OUTPUT_DIR/$folder/$filename"
                echo "  Copied attachment: $filename"
            done
        fi
    fi

    echo "  Done: $folder"
done

# Cleanup
rm -rf "$PROJECT_DIR/DerivedDataScreenshots"

echo ""
echo "================================================"
echo "  All screenshots saved to: $OUTPUT_DIR"
echo "================================================"
ls -la "$OUTPUT_DIR"/*/
