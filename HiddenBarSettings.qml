import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "hiddenBar"

    StyledText {
        width: parent.width
        text: "Hidden Bar Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    // --- Interaction Section ---
    StyledRect {
        width: parent.width
        height: interactionColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: interactionColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Interaction"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

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

            StyledText {
                text: "Right-click the pill icon to pin/unpin the bar when expanded."
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                width: parent.width
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
    }

    // --- Exclusions Section ---
    StyledRect {
        width: parent.width
        height: exclusionColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: exclusionColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Exclusions"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

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
}
