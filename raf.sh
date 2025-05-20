#!/bin/bash
find . -type f \( -name "*.asm" -o -name "*.sh" \) -exec sh -c 'echo "==> {} <=="; cat {}' \;
