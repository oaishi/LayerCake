#!/usr/bin/env bash
# Builds dist/layercake-skill.zip for uploading to Claude.ai / Claude Desktop.
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p dist
rm -f dist/layercake-skill.zip
(cd plugins/layercake/skills && zip -qr ../../../dist/layercake-skill.zip layercake)
echo "Built dist/layercake-skill.zip"
