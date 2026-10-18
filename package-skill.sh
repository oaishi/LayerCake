#!/usr/bin/env bash
# Builds dist/layered-response-skill.zip for uploading to Claude.ai / Claude Desktop.
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p dist
rm -f dist/layered-response-skill.zip
(cd plugins/layered-response/skills && zip -qr ../../../dist/layered-response-skill.zip layered-response)
echo "Built dist/layered-response-skill.zip"
