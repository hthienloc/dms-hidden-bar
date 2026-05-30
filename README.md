# Hidden Bar

Hide unused bar widgets and expand them on demand.

<img src="screenshot.png" width="400" alt="Screenshot">

## Install

Use the DMS CLI:
```bash
dms plugins install hiddenBar
```

Or manually:
```bash
git clone https://github.com/hthienloc/dms-hidden-bar ~/.config/DankMaterialShell/plugins/hiddenBar
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

> [!IMPORTANT]
> **Lưu ý / Note:** 
> - **VI:** Khi mới thêm widget này hoặc thêm các widget khác vào thanh trạng thái (vùng ẩn), bạn cần khởi động lại DankMaterialShell (`dms restart` hoặc tải lại cấu hình) để plugin có thể nhận dạng và quản lý chính xác các widget mới.
> - **EN:** When newly adding this widget or adding other widgets to the status bar (hidden area), you need to restart DankMaterialShell (`dms restart` or reload session) for the plugin to recognize and manage the new widgets.

## IPC Commands

Use `dms ipc call hiddenBar <command>` to control the bar from scripts or keybindings.

| Command | Description |
|---------|-------------|
| `toggle` | Toggle expand/collapse |
| `expand` | Expand the hidden area |
| `collapse` | Collapse the hidden area |
| `pin` | Expand and lock open (disable auto-collapse) |
| `unpin` | Unlock and resume auto-collapse |

### Keybinding examples

**Niri:**
```kdl
bindings {
    Mod+Backslash { spawn "dms" "ipc" "call" "hiddenBar" "toggle"; }
}
```

**Hyprland:**
```ini
bind = SUPER, backslash, exec, dms ipc call hiddenBar toggle
```

## License

GPL-3.0

## Roadmap / TODO
- [ ] **Granular Widget Control:** Settings interface to manually whitelist/blacklist specific widgets for hiding.
- [ ] **Smooth Animations:** Integrated transition effects (Slide, Fade, or Bounce) when expanding/collapsing the hidden area.
- [x] **Global Keybinding:** IPC commands (`toggle`, `expand`, `collapse`, `pin`, `unpin`) for use with any compositor keybinding system.
- [ ] **Space-Aware Auto-Hiding:** Automatically hide more widgets as the screen resolution decreases or bar congestion increases.
- [ ] **Stylized Indicators:** Multiple icon sets and customizable colors for the expansion trigger to match custom themes.
