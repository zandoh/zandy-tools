# ZandyTools

ZandyTools is a modular collection of small, focused quality-of-life tools for World of Warcraft. Rather than one monolithic addon that does everything, ZandyTools lets you pick and choose exactly which tools you want active. Disabled modules are never loaded into memory, keeping things lightweight.

To open the settings panel, type `/zt` or `/zandytools` into chat.

## Modules

### Auto Role Check

Automatically responds to LFG role checks and group role polls with your preferred roles. No more frantically clicking through the role popup before it times out, and no more accidentally queuing as the wrong spec.

- Instantly accepts LFG role checks with your configured roles
- Responds to in-group role polls with Tank > Healer > DPS priority
- Only shows roles your class can actually perform
- Skips auto-response while in combat to avoid protected function errors
- Settings are per-character, so your tank and healer alts stay configured independently

### Keystone Reminder

Shows a popup after completing a Mythic+ dungeon with your new keystone's dungeon and level. Never accidentally push the wrong key because you forgot to check what your keystone depleted into.

- Appears automatically a few seconds after every M+ completion
- Displays the exact dungeon name and key level from your bags
- Dismiss with a single click or press Escape
- Simple, non-intrusive — just a quick reminder, not a whole UI

### Gear Check

Displays visual indicators on the character panel when equipped gear is missing enchants, gems, or available sockets. Never open the Great Vault and realize you forgot to enchant your new ring.

- Shows letter flags (E, G, S) on slot buttons for missing enchants, gems, and sockets
- Hover over an indicator for a plain-English explanation
- Configurable item level threshold to skip low-level gear
- Toggle each check type independently (enchants, gems, sockets)
- Updates dynamically when you equip or modify gear

## Design

- **Truly modular** — each module is a separate LoadOnDemand addon. If you disable a module, it is never loaded. Zero memory, zero CPU.
- **Minimal footprint** — no minimap button, no LibDataBroker feed, no extra frames. Just the tools, nothing else.
- **Per-character settings** — module preferences are stored per-character through AceDB.
- **Single config panel** — everything is managed from one place via `/zt`.

## Slash Commands

- `/zt` — Open the settings panel
- `/zandytools` — Same as above

## Issues & Feedback

Found a bug or have a feature request? Please open an issue on [GitHub](https://github.com/zandoh/ZandyTools).
