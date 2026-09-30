#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "=== Compiling RBRU Masterclass Academic Manual ==="
/Library/TeX/texbin/xelatex -interaction=nonstopmode main.tex
/Library/TeX/texbin/xelatex -interaction=nonstopmode main.tex

if [ -f "main.pdf" ]; then
    echo "=== Compilation Success: main.pdf generated! ==="
    ls -lh main.pdf
else
    echo "=== Compilation Failed! ==="
    exit 1
fi
