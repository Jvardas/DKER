# DKER - DK Enchant Reminder

A minimal World of Warcraft addon that reminds Death Knights if they have the wrong weapon enchant (rune) equipped for their current specialization.

## Features

- **Per-spec configuration** — set an expected Main Hand and Off Hand rune for Blood, Frost, and Unholy independently
- **Per-instance configuration** — set where you want the warning to be shown from Everywhere to just Dungeon or M+ or Raid
- **On-screen warning** — a red, animated message appears in the center of the screen when you join a party with the wrong rune equipped
- **Minimap button** — quick access to the settings panel; right-click to hide the button
- **`/dker`** — opens the settings panel from anywhere
- **`/dker minimap`** — restores a hidden minimap button

## Usage

1. Open the settings panel via the minimap button or `/dker`
2. For each spec, pick the expected Main Hand and Off Hand rune from the dropdowns
3. Settings persist across sessions
4. Join a party — DKER will warn you if your equipped rune doesn't match