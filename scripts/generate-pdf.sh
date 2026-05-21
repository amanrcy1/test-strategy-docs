#!/usr/bin/env bash
#
# generate-pdf.sh — Generates fintech-test-strategy.pdf from strategy markdown files.
#
# Prerequisites:
#   - pandoc (https://pandoc.org/installing.html)
#   - A LaTeX engine (e.g., texlive, tectonic, or basictex)
#
# Usage:
#   ./scripts/generate-pdf.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

STRATEGY_DIR="$PROJECT_ROOT/strategy"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"
OUTPUT_DIR="$PROJECT_ROOT/pdf"
OUTPUT_FILE="$OUTPUT_DIR/fintech-test-strategy.pdf"

# Document metadata
TITLE="Fintech Application Test Strategy"
AUTHOR="QA Portfolio"
DATE="$(date +%Y-%m-%d)"

# Strategy files in order
STRATEGY_FILES=(
  "$STRATEGY_DIR/01-objectives.md"
  "$STRATEGY_DIR/02-scope.md"
  "$STRATEGY_DIR/03-risk-assessment.md"
  "$STRATEGY_DIR/04-coverage-map.md"
  "$STRATEGY_DIR/05-tool-selection.md"
  "$STRATEGY_DIR/06-environments.md"
  "$STRATEGY_DIR/07-entry-exit-criteria.md"
  "$STRATEGY_DIR/08-defect-management.md"
)

# Verify all source files exist
for file in "${STRATEGY_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: Missing strategy file: $file" >&2
    exit 1
  fi
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Generating PDF..."
echo "  Title:  $TITLE"
echo "  Author: $AUTHOR"
echo "  Date:   $DATE"
echo "  Output: $OUTPUT_FILE"

# Generate PDF using pandoc with LaTeX engine
pandoc \
  "${STRATEGY_FILES[@]}" \
  --metadata title="$TITLE" \
  --metadata author="$AUTHOR" \
  --metadata date="$DATE" \
  --toc \
  --toc-depth=3 \
  --pdf-engine=xelatex \
  --variable geometry:margin=1in \
  --variable fontsize=11pt \
  --variable colorlinks=true \
  --variable linkcolor=blue \
  --variable urlcolor=blue \
  --variable toccolor=black \
  --highlight-style=tango \
  -o "$OUTPUT_FILE"

# Verify output exists and check size
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "Error: PDF generation failed — output file not created." >&2
  exit 1
fi

FILE_SIZE=$(wc -c < "$OUTPUT_FILE" | tr -d ' ')
MAX_SIZE=$((20 * 1024 * 1024))  # 20MB in bytes

if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
  echo "Error: Generated PDF exceeds 20MB limit (${FILE_SIZE} bytes)." >&2
  rm -f "$OUTPUT_FILE"
  exit 1
fi

# Human-readable size
if [ "$FILE_SIZE" -gt $((1024 * 1024)) ]; then
  SIZE_DISPLAY="$(echo "scale=2; $FILE_SIZE / 1048576" | bc)MB"
else
  SIZE_DISPLAY="$(echo "scale=2; $FILE_SIZE / 1024" | bc)KB"
fi

echo "Done! PDF generated successfully ($SIZE_DISPLAY)"
