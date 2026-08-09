# Goldphish Match

Goldphish Match is a Godot puzzle game (match rows and columns to clear the board and chain combos). The project targets Godot 4.3 (see project.godot) and the main scene is res://source/menu_state.tscn.

## Quick start

Prerequisites
- Godot 4.3 (or compatible 4.x runtime)
- (Optional) GDScript linter or GUT for tests

Run locally
1. Clone the repo
2. Open the project folder in Godot
3. Run the main scene: Project → Run (or `res://source/menu_state.tscn`)

Export
- This repo includes export_presets.cfg. Configure your export templates in Godot and use the Export dialog to produce builds.

Project layout (top-level)
- source/         Godot scenes and scripts (core game code in source/scripts/)
- assets/         images and icons used by the project
- addons/         Godot addons (uuid is autoloaded)
- export_presets.cfg Godot export presets
- project.godot    Godot project settings (engine version, autoloads, main scene)

Autoloads and notable files
- Autoloads defined in project.godot:
  - GlobalReg -> res://source/scripts/global_reg.gd
  - uuid -> res://addons/uuid/uuid.gd
- Main scene: res://source/menu_state.tscn

Contributing
- If you want to help, please:
  - Use a branch per feature/fix
  - Run a GDScript linter before opening a PR
  - Add tests (GUT) for game logic where possible

License
- This project is available under the MIT License. See LICENSE for details.
