#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <code-server-version>"
  echo "Example: $0 4.102.2"
  exit 1
fi

CODE_SERVER_VERSION=$1
CODE_SERVER_WORKBENCH_PATH="/opt/homebrew/Cellar/code-server/${CODE_SERVER_VERSION}/libexec/lib/vscode/out/vs/code/browser/workbench"
FONT_SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$CODE_SERVER_WORKBENCH_PATH" ]; then
  echo "Error: Directory not found: $CODE_SERVER_WORKBENCH_PATH"
  echo "Please check the code-server version."
  exit 1
fi

echo "Setting up symbolic links for code-server v${CODE_SERVER_VERSION}"

# Remove existing links/directories to avoid errors
echo "Removing existing fonts and fonts.css from workbench..."
rm -rf "${CODE_SERVER_WORKBENCH_PATH}/fonts"
rm -f "${CODE_SERVER_WORKBENCH_PATH}/fonts.css"

# Create symbolic links
echo "Creating new symbolic links..."
ln -s "${FONT_SOURCE_PATH}/fonts" "${CODE_SERVER_WORKBENCH_PATH}/fonts"
ln -s "${FONT_SOURCE_PATH}/fonts.css" "${CODE_SERVER_WORKBENCH_PATH}/fonts.css"

# Patch workbench.html to include custom fonts
WORKBENCH_HTML_PATH="${CODE_SERVER_WORKBENCH_PATH}/workbench.html"
# Use single quotes for HTML attributes to avoid issues with shell expansion
FONT_CSS_LINK="\t\t<link href='{{WORKBENCH_WEB_BASE_URL}}/out/vs/code/browser/workbench/fonts.css' rel='stylesheet' />"

if ! grep -qF "/workbench/fonts.css" "$WORKBENCH_HTML_PATH"; then
  echo "Patching workbench.html to include custom fonts..."
  # Using 's' command with a different delimiter for better portability (works on macOS/BSD sed)
  sed -i '' "s,<!-- Workbench Icon/Manifest/CSS -->,&\n  ${FONT_CSS_LINK}," "$WORKBENCH_HTML_PATH"
else
  echo "Custom fonts already linked in workbench.html."
fi

echo "Done."
