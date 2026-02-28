#!/bin/bash
# Setup script for houdini-mcp-actual on macOS + Houdini 21.0
# Run this from the houdini-mcp-actual repo directory

set -e

HOUDINI_PREFS="$HOME/Library/Preferences/houdini/21.0"
PLUGIN_DIR="$HOUDINI_PREFS/scripts/python/houdinimcp"
PACKAGES_DIR="$HOUDINI_PREFS/packages"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Houdini MCP Setup (macOS) ==="
echo "Houdini prefs: $HOUDINI_PREFS"
echo "Repo location: $REPO_DIR"
echo ""

# Step 1: Create directories
echo "1. Creating directories..."
mkdir -p "$PLUGIN_DIR"
mkdir -p "$PACKAGES_DIR"

# Step 2: Clear stale bytecode cache
echo "2. Clearing stale __pycache__..."
rm -rf "$PLUGIN_DIR/__pycache__"

# Step 3: Copy plugin files
echo "3. Copying plugin files to $PLUGIN_DIR ..."
cp "$REPO_DIR/__init__.py"           "$PLUGIN_DIR/"
cp "$REPO_DIR/server.py"             "$PLUGIN_DIR/"
cp "$REPO_DIR/houdini_mcp_server.py" "$PLUGIN_DIR/"
cp "$REPO_DIR/HoudiniMCPRender.py"   "$PLUGIN_DIR/"
cp "$REPO_DIR/pyproject.toml"        "$PLUGIN_DIR/"
if [ -f "$REPO_DIR/urls.env" ]; then
    cp "$REPO_DIR/urls.env"          "$PLUGIN_DIR/"
fi

# Step 4: Copy package file for auto-loading
echo "4. Installing Houdini package file..."
cp "$REPO_DIR/houdinimcp_package.json" "$PACKAGES_DIR/houdinimcp.json"

# Step 5: Install MCP dependency via uv
echo "5. Installing MCP dependency..."
cd "$PLUGIN_DIR"
if command -v uv &> /dev/null; then
    uv add "mcp[cli]"
else
    echo "   WARNING: uv not found. Install it first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "   Then re-run this script."
    exit 1
fi

# Step 6: Update Claude Desktop config
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo "6. Claude Desktop config"
echo "   Add this to: $CLAUDE_CONFIG"
echo ""
echo '  {
    "mcpServers": {
      "houdini": {
        "command": "uv",
        "args": [
          "run",
          "python",
          "'"$PLUGIN_DIR/houdini_mcp_server.py"'"
        ]
      }
    }
  }'
echo ""

echo "=== Done! ==="
echo ""
echo "Next steps:"
echo "  1. Add the config above to Claude Desktop (Settings > Developer > Edit Config)"
echo "  2. Restart Houdini"
echo "  3. Create the shelf tool to toggle the MCP server (see README)"
echo "  4. Click the shelf tool to start the server, then restart Claude Desktop"
