#!/bin/bash

#######################################
# ZandyTools Quick Start Script
# Auto-detects WoW installation and creates symlinks
#######################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ADDON_NAME="ZandyTools"

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}ZandyTools Quick Start${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""

# Function to check if directory exists and is valid
check_wow_dir() {
	local dir=$1
	if [ -d "$dir/Interface/AddOns" ]; then
		return 0
	fi
	return 1
}

# Function to find WoW installation
find_wow_installation() {
	local wow_paths=(
		# macOS common paths
		"$HOME/Applications/World of Warcraft/_retail_"
		"/Applications/World of Warcraft/_retail_"
		"$HOME/Games/World of Warcraft/_retail_"

		# Windows (via WSL) common paths
		"/mnt/c/Program Files (x86)/World of Warcraft/_retail_"
		"/mnt/c/Program Files/World of Warcraft/_retail_"

		# Linux common paths
		"$HOME/.wine/drive_c/Program Files (x86)/World of Warcraft/_retail_"
		"$HOME/Games/world-of-warcraft/_retail_"
	)

	for path in "${wow_paths[@]}"; do
		if check_wow_dir "$path"; then
			echo "$path"
			return 0
		fi
	done

	return 1
}

# Auto-detect WoW installation
echo -e "${YELLOW}Searching for World of Warcraft installation...${NC}"
WOW_DIR=$(find_wow_installation)

if [ -n "$WOW_DIR" ]; then
	echo -e "${GREEN}✓ Found WoW at: $WOW_DIR${NC}"
else
	echo -e "${YELLOW}Could not auto-detect WoW installation${NC}"
	echo ""
	read -p "Enter path to WoW _retail_ directory: " WOW_DIR

	if ! check_wow_dir "$WOW_DIR"; then
		echo -e "${RED}Error: Invalid WoW directory${NC}"
		echo "Please ensure the path contains Interface/AddOns"
		exit 1
	fi
fi

ADDON_DIR="$WOW_DIR/Interface/AddOns"
ADDON_PATH="$ADDON_DIR/$ADDON_NAME"
CURRENT_DIR="$(pwd)"

echo ""
echo -e "${YELLOW}AddOns directory: $ADDON_DIR${NC}"
echo ""

# Check if addon already exists
if [ -L "$ADDON_PATH" ]; then
	echo -e "${YELLOW}Symlink already exists${NC}"
	read -p "Remove and recreate? [y/N]: " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		rm "$ADDON_PATH"
		echo -e "${GREEN}✓ Old symlink removed${NC}"
	else
		echo -e "${YELLOW}Skipping symlink creation${NC}"
		exit 0
	fi
elif [ -e "$ADDON_PATH" ]; then
	echo -e "${RED}Error: $ADDON_NAME already exists and is not a symlink${NC}"
	echo "Please remove it manually first: rm -rf '$ADDON_PATH'"
	exit 1
fi

# Create symlink
echo -e "${YELLOW}Creating symlink...${NC}"
ln -s "$CURRENT_DIR" "$ADDON_PATH"

if [ -L "$ADDON_PATH" ]; then
	echo -e "${GREEN}✓ Symlink created successfully${NC}"
	echo ""
	echo -e "${GREEN}==================================${NC}"
	echo -e "${GREEN}Setup Complete!${NC}"
	echo -e "${GREEN}==================================${NC}"
	echo ""
	echo "Next steps:"
	echo "  1. Start World of Warcraft"
	echo "  2. Type /as or /addonsuite in chat"
	echo "  3. Enable modules in the configuration"
	echo ""
	echo "Development commands:"
	echo "  make help          - Show all available commands"
	echo "  make check         - Run code validation"
	echo "  make new-module    - Create a new module"
	echo "  make unlink        - Remove symlink"
	echo ""
	echo "Happy coding!"
else
	echo -e "${RED}Error: Failed to create symlink${NC}"
	exit 1
fi
