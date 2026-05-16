# Hidden Bar

Hide unused bar widgets and expand them on demand.

<img src="screenshot.png" width="400" alt="Screenshot">

## Install


**Required:** This plugin requires [dms-common](https://github.com/hthienloc/dms-common) to be installed.

```bash
# 1. Install shared components
git clone https://github.com/hthienloc/dms-common ~/.config/DankMaterialShell/plugins/dms-common

# 2. Install this plugin
dms plugins install hiddenBar
```

Or manually:
```bash
git clone https://github.com/hthienloc/dms-hidden-bar ~/.config/DankMaterialShell/plugins/hidden-bar
```

## Features

- **Smart hide** - Collapse widgets to save bar space
- **Hover to expand** - Reveal hidden widgets by hovering over the trigger area
- **Auto-collapse** - Hide again after inactivity
- **Exclude items** - Keep system tray or clock always visible

## Usage

| Action | Result |
|--------|--------|
| Left click | Toggle expand |
| Right click | Pin/unpin expanded state |

## License

GPL-3.0

## Roadmap / TODO
- [ ] **Granular Widget Control:** Settings interface to manually whitelist/blacklist specific widgets for hiding.
- [ ] **Smooth Animations:** Integrated transition effects (Slide, Fade, or Bounce) when expanding/collapsing the hidden area.
- [ ] **Global Keybinding:** Support for a user-defined hotkey to trigger expansion without using the mouse.
- [ ] **Space-Aware Auto-Hiding:** Automatically hide more widgets as the screen resolution decreases or bar congestion increases.
- [ ] **Stylized Indicators:** Multiple icon sets and customizable colors for the expansion trigger to match custom themes.
