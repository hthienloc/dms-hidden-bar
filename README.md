# Hidden Bar

A plugin for Dank Material Shell to manage bar widget visibility.

<img src="screenshot.png" width="400" alt="Screenshot">

## Features

- Click to toggle visibility of widgets.
- Auto-expansion on hover (enabled by default).
- **Extended Trigger Area**: Hover over the space previously occupied by hidden widgets to expand.
- Optional automatic collapse after inactivity.
- **Max hidden widgets**: Limit the number of widgets to hide.
- **Initial state**: Choose whether to start expanded or minimized.
- Settings to exclude System Tray and Clock from being hidden.

## Installation

```bash
# Clone the repository
git clone https://github.com/hthienloc/dms-hidden-bar.git

# Create symlink in DMS plugins folder
ln -s /path/to/dms-hidden-bar ~/.config/DankMaterialShell/plugins/hidden-bar
```

## Enable in DMS

1. Open DMS Settings → Plugins
2. Click "Scan for Plugins" or reload
3. Enable "Hidden Bar" plugin
4. Add to DankBar widget list

## Settings

### Interaction
- **Auto-expand on hover**: Automatically show widgets when hovering over the icon.
- **Extended Trigger Area**: Allow triggering expansion by hovering over the "empty" space where widgets are hidden.
- **Hover delay**: Delay in milliseconds before expansion.
- **Auto-collapse**: Hide widgets automatically after a period.
- **Collapse delay**: Duration in milliseconds before hiding (supports 0ms).
- **Max hidden widgets**: Specify a limit on how many widgets to hide (0 = all).
- **Start expanded**: Determine the initial state when the plugin is loaded.

### Exclusions
- **Keep System Tray**: Do not hide the system tray.
- **Keep Clock**: Do not hide the clock.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
