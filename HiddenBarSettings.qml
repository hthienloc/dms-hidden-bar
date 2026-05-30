import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "./dms-common"

PluginSettings {
    id: root
    pluginId: "hiddenBar"

    SettingsCard {
        SectionTitle { text: I18n.tr("Usage Guide"); icon: "help" }
        UsageGuide {
            items: [
                I18n.tr("<b>Hover</b> the icon to temporarily expand the hidden area."),
                I18n.tr("<b>Left-click</b> to toggle expanded state manually."),
                I18n.tr("<b>Right-click</b> to <b>PIN</b> (prevent auto-collapse) when expanded.")
            ]
        }
    }

    NoteCard {
        title: I18n.tr("Note")
        icon: "warning"
        text: I18n.tr("Please run 'dms restart' after adding widgets to the status bar for changes to take effect.")
    }

    SettingsCard {
        SectionTitle { text: I18n.tr("Expansion & Collapse"); icon: "unfold_more" }

        ToggleSetting {
            label: I18n.tr("Start expanded")
            description: I18n.tr("Whether the bar should be expanded when the plugin starts.")
            settingKey: "startExpanded"
            defaultValue: false
        }

        ToggleSetting {
            label: I18n.tr("Auto-expand on hover")
            description: I18n.tr("Expand the bar automatically when hovering over the icon.")
            settingKey: "autoExpand"
            defaultValue: true
        }

        SliderSetting {
            label: I18n.tr("Hover delay")
            description: I18n.tr("Wait time (ms) before expanding on hover.")
            settingKey: "hoverDelay"
            defaultValue: 0
            minimum: 0
            maximum: 1000
            unit: "ms"
        }

        ToggleSetting {
            label: I18n.tr("Auto-collapse")
            description: I18n.tr("Automatically collapse the bar after a period of inactivity.")
            settingKey: "autoCollapse"
            defaultValue: true
        }

        SliderSetting {
            label: I18n.tr("Collapse delay")
            description: I18n.tr("Wait time (ms) before collapsing automatically.")
            settingKey: "collapseDelay"
            defaultValue: 1000
            minimum: 0
            maximum: 10000
            unit: "ms"
            enabled: (root.pluginData?.autoCollapse) ?? true
        }
    }

    SettingsCard {
        SectionTitle { text: I18n.tr("Trigger Zone"); icon: "ads_click" }

        ToggleSetting {
            label: I18n.tr("Extended trigger area")
            description: I18n.tr("Allow triggering expansion by hovering over the area where icons are hidden.")
            settingKey: "extendedTrigger"
            defaultValue: true
        }

        ToggleSetting {
            label: I18n.tr("Show region preview")
            description: I18n.tr("Highlight the expansion trigger zone")
            settingKey: "showRegionPreview"
            defaultValue: false
        }

        SliderSetting {
            label: I18n.tr("Trigger area adjustment")
            description: I18n.tr("Fine-tune the trigger zone size. Positive values expand it, negative values shrink it.")
            settingKey: "triggerAdjustment"
            defaultValue: 0
            minimum: -150
            maximum: 500
            unit: "px"
        }
    }

    SettingsCard {
        SectionTitle { text: I18n.tr("Exclusions"); icon: "block" }

        ToggleSetting {
            label: I18n.tr("Keep System Tray")
            description: I18n.tr("Never hide the system tray widgets.")
            settingKey: "excludeTray"
            defaultValue: true
        }

        ToggleSetting {
            label: I18n.tr("Keep Clock")
            description: I18n.tr("Never hide the clock widget.")
            settingKey: "excludeClock"
            defaultValue: true
        }

        SliderSetting {
            label: I18n.tr("Max hidden widgets")
            description: I18n.tr("Limit the number of widgets to hide. Set to 0 to hide all.")
            settingKey: "hideCount"
            defaultValue: 0
            minimum: 0
            maximum: 20
            unit: ""
        }
    }

    PluginAbout {
        repoUrl: "https://github.com/hthienloc/dms-hidden-bar"
    }
}
