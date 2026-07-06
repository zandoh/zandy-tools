# ZandyTools

[![CI](https://github.com/zandoh/zandy-tools/actions/workflows/ci.yml/badge.svg)](https://github.com/zandoh/zandy-tools/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/zandoh/zandy-tools)](https://github.com/zandoh/zandy-tools/releases)
[![WoW Retail](https://img.shields.io/badge/WoW-Retail%2012.0.1-blue)](https://worldofwarcraft.blizzard.com)
[![License: MIT](https://img.shields.io/github/license/zandoh/zandy-tools)](LICENSE)

A modular quality-of-life addon suite for World of Warcraft. Each tool ships as a separate LoadOnDemand addon on top of a shared Ace3 core, so disabled modules are never loaded — zero memory, zero CPU.

**Website:** [zandoh.github.io/zandy-tools](https://zandoh.github.io/zandy-tools/)

## Modules

| Module | Description |
| --- | --- |
| **Role Check** | Automatically responds to LFG role checks and group role polls with your preferred roles. Only offers roles your class can perform, and stays quiet during combat to avoid protected-function errors. |
| **Gear Check** | Flags equipped items on the character panel that are missing enchants, gems, or available sockets, with tooltips explaining each indicator. Includes a configurable item-level threshold and per-check toggles. |
| **Keystone Reminder** | Shows a popup with your new keystone's dungeon and level after completing a Mythic+ run, so you never push the wrong key. |

All settings are per-character and managed from a single configuration panel.

## Installation

Install from [CurseForge](https://www.curseforge.com/wow/addons/zandytools), [Wago](https://addons.wago.io/addons/zandytools), or download the latest packaged zip from [GitHub Releases](https://github.com/zandoh/zandy-tools/releases) and extract it into:

```
World of Warcraft/_retail_/Interface/AddOns/
```

**Requirements:** World of Warcraft Retail 12.0.1 or later.

## Usage

Open the configuration panel with either slash command:

```
/zt
/zandytools
```

From there you can enable or disable individual modules and adjust their settings.

## Development

Clone the repository and symlink it into your AddOns directory:

```sh
make dev                                  # install deps check + symlink
make link WOW_ADDON_DIR=/path/to/AddOns   # custom WoW location
make check                                # run luacheck, stylua, and TOC graph checks
make fmt                                  # format Lua sources with StyLua
make package                              # build a release zip (BigWigsMods packager)
```

Alternatively, `./quickstart.sh` auto-detects your WoW installation and creates the symlink for you.

Releases are automated: pushing a `v*` tag packages the addon, publishes to CurseForge and Wago, and creates a GitHub Release.

## Contributing

Bug reports and feature requests are welcome — please [open an issue](https://github.com/zandoh/zandy-tools/issues). Commits follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## License

[MIT](LICENSE)
