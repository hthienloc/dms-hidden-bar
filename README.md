# Hidden Bar

Hide unused bar widgets and expand them on demand.

<img src="screenshot.png" width="400" alt="Screenshot">

## Install


**Required:** This plugin requires [dms-common](https://github.com/hthienloc/dms-common) to be installed.

```bash
# 1. Install shared components
git clone https://github.com/hthienloc/dms-common ~/.config/DankMaterialShell/plugins/dms-common

# 2. Install this plugin
dms://plugin/install/hiddenBar
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
- [ ] **Manual Widget Selection**: Add a checklist in settings to explicitly include or exclude specific widgets regardless of their position.
- [ ] **Transition Animations**: Implement customizable animation presets (Fade, Scale, or Slide) for a more polished reveal effect.
- [ ] **Global Shortcut**: Add support for a keyboard shortcut to toggle the expanded state globally.
- [ ] **Dynamic Priority**: Automatically hide widgets based on available screen space or active window constraints.
