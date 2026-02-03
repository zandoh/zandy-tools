.PHONY: help link unlink package clean new-module dev check watch install-deps

# Default WoW addon directory (can be overridden)
WOW_ADDON_DIR ?= $(HOME)/Applications/World\ of\ Warcraft/_retail_/Interface/AddOns

# Addon name
ADDON_NAME = ZandyTools

# Colors for output
COLOR_RESET = \033[0m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m

help:
	@echo "$(COLOR_BLUE)ZandyTools Development Makefile$(COLOR_RESET)"
	@echo ""
	@echo "Available commands:"
	@echo "  $(COLOR_GREEN)make link$(COLOR_RESET)         - Create symlink to WoW AddOns directory"
	@echo "  $(COLOR_GREEN)make unlink$(COLOR_RESET)       - Remove symlink from WoW AddOns directory"
	@echo "  $(COLOR_GREEN)make package$(COLOR_RESET)      - Create release package (requires packager)"
	@echo "  $(COLOR_GREEN)make clean$(COLOR_RESET)        - Clean build artifacts"
	@echo "  $(COLOR_GREEN)make new-module$(COLOR_RESET)   - Create a new module from template"
	@echo "  $(COLOR_GREEN)make dev$(COLOR_RESET)          - Set up development environment"
	@echo "  $(COLOR_GREEN)make check$(COLOR_RESET)        - Run syntax and quality checks"
	@echo "  $(COLOR_GREEN)make watch$(COLOR_RESET)        - Watch for file changes and run checks"
	@echo "  $(COLOR_GREEN)make install-deps$(COLOR_RESET) - Install development dependencies"
	@echo ""
	@echo "Override WoW directory with: make link WOW_ADDON_DIR=/path/to/addons"

link:
	@echo "$(COLOR_YELLOW)Linking addon to WoW...$(COLOR_RESET)"
	@if [ ! -d "$(WOW_ADDON_DIR)" ]; then \
		echo "$(COLOR_YELLOW)Error: WoW AddOns directory not found at $(WOW_ADDON_DIR)$(COLOR_RESET)"; \
		echo "Use: make link WOW_ADDON_DIR=/path/to/addons"; \
		exit 1; \
	fi
	@if [ -L "$(WOW_ADDON_DIR)/$(ADDON_NAME)" ]; then \
		echo "$(COLOR_YELLOW)Symlink already exists$(COLOR_RESET)"; \
	elif [ -d "$(WOW_ADDON_DIR)/$(ADDON_NAME)" ]; then \
		echo "$(COLOR_YELLOW)Error: Directory $(ADDON_NAME) already exists (not a symlink)$(COLOR_RESET)"; \
		exit 1; \
	else \
		ln -s "$(PWD)" "$(WOW_ADDON_DIR)/$(ADDON_NAME)"; \
		echo "$(COLOR_GREEN)✓ Symlink created: $(WOW_ADDON_DIR)/$(ADDON_NAME)$(COLOR_RESET)"; \
	fi

unlink:
	@echo "$(COLOR_YELLOW)Unlinking addon from WoW...$(COLOR_RESET)"
	@if [ -L "$(WOW_ADDON_DIR)/$(ADDON_NAME)" ]; then \
		rm "$(WOW_ADDON_DIR)/$(ADDON_NAME)"; \
		echo "$(COLOR_GREEN)✓ Symlink removed$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)No symlink found$(COLOR_RESET)"; \
	fi

package:
	@echo "$(COLOR_YELLOW)Creating release package...$(COLOR_RESET)"
	@if [ ! -f "release.sh" ]; then \
		echo "$(COLOR_YELLOW)Downloading BigWigsMods packager...$(COLOR_RESET)"; \
		curl -s https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh -o release.sh; \
		chmod +x release.sh; \
	fi
	@./release.sh -d -z
	@echo "$(COLOR_GREEN)✓ Package created in .release/$(COLOR_RESET)"

clean:
	@echo "$(COLOR_YELLOW)Cleaning build artifacts...$(COLOR_RESET)"
	@rm -rf .release
	@rm -f release.sh
	@rm -f *.zip
	@echo "$(COLOR_GREEN)✓ Clean complete$(COLOR_RESET)"

new-module:
	@echo "$(COLOR_BLUE)Create a new module$(COLOR_RESET)"
	@read -p "Module name (e.g., MyNewTool): " MODULE_NAME; \
	MODULE_FILE="Modules/$${MODULE_NAME}.lua"; \
	if [ -f "$${MODULE_FILE}" ]; then \
		echo "$(COLOR_YELLOW)Error: Module $${MODULE_FILE} already exists$(COLOR_RESET)"; \
		exit 1; \
	fi; \
	echo "Creating $${MODULE_FILE}..."; \
	sed "s/ExampleTool/$${MODULE_NAME}/g" Modules/ExampleTool.lua > "$${MODULE_FILE}"; \
	echo "$(COLOR_GREEN)✓ Module created: $${MODULE_FILE}$(COLOR_RESET)"; \
	echo "$(COLOR_YELLOW)Don't forget to add it to ZandyTools.toc!$(COLOR_RESET)"

dev: install-deps link
	@echo "$(COLOR_GREEN)✓ Development environment ready$(COLOR_RESET)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Start WoW to test your addon"
	@echo "  2. Run 'make check' to validate your code"
	@echo "  3. Run 'make watch' for live validation"

check:
	@echo "$(COLOR_YELLOW)Running checks...$(COLOR_RESET)"
	@if command -v luacheck >/dev/null 2>&1; then \
		echo "Running luacheck..."; \
		luacheck . --exclude-files 'Libs/' '.release/' || true; \
	else \
		echo "$(COLOR_YELLOW)luacheck not installed, skipping Lua validation$(COLOR_RESET)"; \
		echo "Install with: luarocks install luacheck"; \
	fi
	@if [ ! -f "ZandyTools.toc" ]; then \
		echo "$(COLOR_YELLOW)Error: ZandyTools.toc not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_GREEN)✓ Checks complete$(COLOR_RESET)"

watch:
	@echo "$(COLOR_YELLOW)Watching for changes... (Ctrl+C to stop)$(COLOR_RESET)"
	@if command -v fswatch >/dev/null 2>&1; then \
		fswatch -o Core/ Modules/ *.lua | xargs -n1 -I{} make check; \
	else \
		echo "$(COLOR_YELLOW)fswatch not installed$(COLOR_RESET)"; \
		echo "Install with: brew install fswatch (macOS) or apt-get install fswatch (Linux)"; \
		exit 1; \
	fi

install-deps:
	@echo "$(COLOR_YELLOW)Checking development dependencies...$(COLOR_RESET)"
	@if command -v lua >/dev/null 2>&1; then \
		echo "$(COLOR_GREEN)✓ Lua installed$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)⚠ Lua not installed$(COLOR_RESET)"; \
		echo "Install with: brew install lua (macOS) or apt-get install lua5.1 (Linux)"; \
	fi
	@if command -v luarocks >/dev/null 2>&1; then \
		echo "$(COLOR_GREEN)✓ LuaRocks installed$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)⚠ LuaRocks not installed$(COLOR_RESET)"; \
		echo "Install with: brew install luarocks (macOS) or apt-get install luarocks (Linux)"; \
	fi
	@if command -v luacheck >/dev/null 2>&1; then \
		echo "$(COLOR_GREEN)✓ luacheck installed$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)⚠ luacheck not installed$(COLOR_RESET)"; \
		echo "Install with: luarocks install luacheck"; \
	fi
	@echo ""
	@echo "$(COLOR_GREEN)✓ Dependency check complete$(COLOR_RESET)"
