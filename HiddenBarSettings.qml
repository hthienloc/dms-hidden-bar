import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "../dms-common"

PluginSettings {
    id: root
    pluginId: "hiddenBar"

    PluginHeader {
        title: "Hidden Bar"
        description: "Organize your bar by hiding secondary widgets behind a sleek expansion zone."
    }

    SettingsCard {
        SectionTitle { text: "Usage Guide" }
        UsageGuide {
            items: [
                "<b>Hover</b> the icon to temporarily expand the hidden area.",
                "<b>Left-click</b> to toggle expanded state manually.",
                "<b>Right-click</b> to <b>PIN</b> (prevent auto-collapse) when expanded."
            ]
        }
    }

    SettingsCard {
        SectionTitle { text: "Interaction" }

        ToggleSetting {
            label: "Auto-expand on hover"
            description: "Expand the bar automatically when hovering over the icon."
            settingKey: "autoExpand"
            defaultValue: true
        }

        SliderSetting {
            label: "Hover delay"
            description: "Wait time (ms) before expanding on hover."
            settingKey: "hoverDelay"
            defaultValue: 0
            minimum: 0
            maximum: 1000
            unit: "ms"
        }

        ToggleSetting {
            label: "Auto-collapse"
            description: "Automatically collapse the bar after a period of inactivity."
            settingKey: "autoCollapse"
            defaultValue: true
        }

        SliderSetting {
            label: "Collapse delay"
            description: "Wait time (ms) before collapsing automatically."
            settingKey: "collapseDelay"
            defaultValue: 1000
            minimum: 0
            maximum: 10000
            unit: "ms"
            enabled: root.pluginData.autoCollapse ?? true
        }

        ToggleSetting {
            label: "Extended trigger area"
            description: "Allow triggering expansion by hovering over the area where icons are hidden."
            settingKey: "extendedTrigger"
            defaultValue: true
        }

        ToggleSetting {
            label: "Start expanded"
            description: "Whether the bar should be expanded when the plugin starts."
            settingKey: "startExpanded"
            defaultValue: false
        }
    }

    SettingsCard {
        SectionTitle { text: "Exclusions" }

        ToggleSetting {
            label: "Keep System Tray"
            description: "Never hide the system tray widgets."
            settingKey: "excludeTray"
            defaultValue: true
        }

        ToggleSetting {
            label: "Keep Clock"
            description: "Never hide the clock widget."
            settingKey: "excludeClock"
            defaultValue: true
        }

        SliderSetting {
            label: "Max hidden widgets"
            description: "Limit the number of widgets to hide. Set to 0 to hide all."
            settingKey: "hideCount"
            defaultValue: 0
            minimum: 0
            maximum: 20
            unit: ""
        }
    }
}
