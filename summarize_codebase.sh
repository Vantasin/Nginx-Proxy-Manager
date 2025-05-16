#!/bin/bash

# Smart Summarize Codebase Script
# Usage: ./summarize_codebase.sh /path/to/project

# Set project directory (default = current dir)
PROJECT_DIR="${1:-.}"

# Output file
OUTPUT_FILE="codebase_summary.txt"

# Clear output if it exists
> "$OUTPUT_FILE"

echo "Summarizing project at: $PROJECT_DIR"
echo "Saving to: $OUTPUT_FILE"
echo ""

# Header
echo "Project Path: $PROJECT_DIR" >> "$OUTPUT_FILE"
echo "Date: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ----------------------------------
# 1. Folder Structure (tree view)
# ----------------------------------
echo "Folder Structure:" >> "$OUTPUT_FILE"
echo "------------------" >> "$OUTPUT_FILE"

# Make sure tree is installed
if ! command -v tree &> /dev/null; then
    echo "Error: 'tree' command not found. Please install it (brew install tree)." >&2
    exit 1
fi

tree -I "node_modules|.git|__pycache__|dist|build|venv|.venv" -L 4 "$PROJECT_DIR" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ----------------------------------
# 2. Important Files (source code snippets)
# ----------------------------------
echo "Important Files (First 300 Lines Each):" >> "$OUTPUT_FILE"
echo "--------------------------------------" >> "$OUTPUT_FILE"

# Find source code files only
# Write contents of files in TREE ORDER
find "$PROJECT_DIR" -type f \
    \( -iname "*.py" -o -iname "*.js" -o -iname "*.ts" -o -iname "*.html" -o -iname "*.css" \
    -o -iname "*.json" -o -iname "*.xml" -o -iname "*.yaml" -o -iname "*.yml" -o -iname "*.md" \
    -o -iname "*.sh" -o -iname "*.txt" -o -iname "*.cfg" -o -iname "*.ini" \
    -o -type f ! -name "*.*" \) \
    ! \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.svg" \
    -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.zip" \
    -o -iname "*.tar" -o -iname "*.gz" -o -iname "*.exe" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/venv/*" \
    -not -path "*/.venv/*" \
    | sort | head -n 30 | while read -r file; do
        filename=$(basename "$file")
        echo "============================================================" >> "$OUTPUT_FILE"
        echo "File Name: $filename" >> "$OUTPUT_FILE"
        echo "File Path: $file" >> "$OUTPUT_FILE"
        echo "============================================================" >> "$OUTPUT_FILE"
        head -n 300 "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done

# ----------------------------------
# 3. List Requirements / Dependencies
# ----------------------------------
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    echo "Python Requirements:" >> "$OUTPUT_FILE"
    echo "---------------------" >> "$OUTPUT_FILE"
    cat "$PROJECT_DIR/requirements.txt" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

if [ -f "$PROJECT_DIR/package.json" ]; then
    echo "Node.js Dependencies (package.json):" >> "$OUTPUT_FILE"
    echo "-------------------------------------" >> "$OUTPUT_FILE"
    jq .dependencies "$PROJECT_DIR/package.json" >> "$OUTPUT_FILE" 2>/dev/null || cat "$PROJECT_DIR/package.json" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

echo "Summary Complete! See $OUTPUT_FILE."
