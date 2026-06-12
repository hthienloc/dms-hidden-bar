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

    NoteCard {
        title: I18n.tr("Note")
        icon: "warning"
        text: I18n.tr("Please run 'dms restart' after adding widgets to the status bar for changes to take effect.")
    }

    SettingsCard {
        id: expansionSection
        SectionTitle { 
            text: I18n.tr("Expansion & Collapse")
            icon: "unfold_more" 
            showReset: usePopout.isDirty || popoutLayout.isDirty || startExpanded.isDirty || autoExpand.isDirty || hoverDelay.isDirty || autoCollapse.isDirty || collapseDelay.isDirty
            onResetClicked: {
                usePopout.resetToDefault();
                popoutLayout.resetToDefault();
                startExpanded.resetToDefault();
                autoExpand.resetToDefault();
                hoverDelay.resetToDefault();
                autoCollapse.resetToDefault();
                collapseDelay.resetToDefault();
            }
        }

        ToggleSettingPlus {
            id: usePopout
            label: I18n.tr("Use Popout Overflow")
            description: I18n.tr("Show hidden plugins in a separate popout menu instead of expanding the status bar.")
            settingKey: "usePopout"
            defaultValue: false
        }

        StyledText {
            visible: usePopout.value
            text: "⚠️ " + I18n.tr("Recommendation: Disable 'Auto-collapse' when using Popout mode as it is currently unstable.")
            color: Theme.error
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
            width: parent.width
            leftPadding: Theme.spacingM
            rightPadding: Theme.spacingM
            bottomPadding: Theme.spacingS
            height: visible ? implicitHeight : 0
        }

        Separator {
            visible: popoutLayout.visible || startExpanded.visible
            height: visible ? 1 : 0
        }

        SelectionSettingPlus {
            id: popoutLayout
            label: I18n.tr("Popout Layout")
            description: I18n.tr("How icons are arranged inside the popout.")
            settingKey: "popoutLayout"
            defaultValue: "row"
            options: [
                { label: I18n.tr("Horizontal Row"), value: "row" },
                { label: I18n.tr("Grid"), value: "grid" }
            ]
            visible: usePopout.value
            height: visible ? implicitHeight : 0
        }

        Separator {
            visible: popoutWidthAdjustment.visible
            height: visible ? 1 : 0
        }

        SliderSettingPlus {
            id: popoutWidthAdjustment
            label: I18n.tr("Popout width adjustment")
            description: I18n.tr("Fine-tune the horizontal popout width.")
            settingKey: "popoutWidthAdjustment"
            defaultValue: 48
            minimum: -150
            maximum: 150
            unit: "px"
            leftLabel: "-150"
            rightLabel: "150"
            visible: usePopout.value && popoutLayout.value === "row"
            height: visible ? implicitHeight : 0
        }

        Separator {
            visible: popoutHeightAdjustment.visible
            height: visible ? 1 : 0
        }

        SliderSettingPlus {
            id: popoutHeightAdjustment
            label: I18n.tr("Popout height adjustment")
            description: I18n.tr("Fine-tune the popout height.")
            settingKey: "popoutHeightAdjustment"
            defaultValue: 6
            minimum: -150
            maximum: 150
            unit: "px"
            leftLabel: "-150"
            rightLabel: "150"
            visible: usePopout.value
            height: visible ? implicitHeight : 0
        }

        ToggleSettingPlus {
            id: startExpanded
            label: I18n.tr("Start expanded")
            settingKey: "startExpanded"
            defaultValue: false
            visible: !usePopout.value
            height: visible ? implicitHeight : 0
        }

        Separator {
            visible: true
        }

        ToggleSettingPlus {
            id: autoExpand
            label: I18n.tr("Auto-expand on hover")
            settingKey: "autoExpand"
            defaultValue: true
        }

        Separator {
            visible: autoExpand.value
            height: visible ? 1 : 0
        }

        SliderSettingPlus {
            id: hoverDelay
            label: I18n.tr("Hover delay")
            description: I18n.tr("Wait time before expanding on hover.")
            settingKey: "hoverDelay"
            defaultValue: 0
            minimum: 0
            maximum: 1000
            unit: "ms"
            leftLabel: "0"
            rightLabel: "1000"
            visible: autoExpand.value
            height: visible ? implicitHeight : 0
        }

        Separator {}

        ToggleSettingPlus {
            id: autoCollapse
            label: I18n.tr("Auto-collapse")
            settingKey: "autoCollapse"
            defaultValue: true
        }

        SliderSettingPlus {
            id: collapseDelay
            label: I18n.tr("Collapse delay")
            description: I18n.tr("Wait time before collapsing automatically.")
            settingKey: "collapseDelay"
            defaultValue: 1
            minimum: 0
            maximum: 10
            unit: "s"
            leftLabel: "0"
            rightLabel: "10"
            visible: autoCollapse.value
            height: visible ? implicitHeight : 0
        }

        Separator {
            visible: autoCollapse.value
            height: visible ? 1 : 0
        }

        ToggleSettingPlus {
            id: hideIconPillWhenCollapsed
            label: I18n.tr("Hide icon pill when collapsed")
            description: I18n.tr("Completely hide the trigger icon pill when the bar is collapsed.")
            settingKey: "hideIconPillWhenCollapsed"
            defaultValue: false
        }

        Separator {}

        ToggleSettingPlus {
            id: hideIconPillWhenExpanded
            label: I18n.tr("Hide icon pill when expanded")
            description: I18n.tr("Completely hide the trigger icon pill when the bar is expanded.")
            settingKey: "hideIconPillWhenExpanded"
            defaultValue: false
        }
    }

    SettingsCard {
        id: triggerSection
        SectionTitle { 
            text: I18n.tr("Trigger Zone")
            icon: "ads_click" 
            showReset: extendedTrigger.isDirty || showRegionPreview.isDirty || triggerAdjustment.isDirty
            onResetClicked: {
                extendedTrigger.resetToDefault();
                showRegionPreview.resetToDefault();
                triggerAdjustment.resetToDefault();
            }
        }

        ToggleSettingPlus {
            id: extendedTrigger
            label: I18n.tr("Extended trigger area")
            description: I18n.tr("Allow triggering expansion by hovering over the area where icons are hidden.")
            settingKey: "extendedTrigger"
            defaultValue: true
        }

        Separator {}

        ToggleSettingPlus {
            id: showRegionPreview
            label: I18n.tr("Show region preview")
            description: I18n.tr("Highlight the expansion trigger zone.")
            settingKey: "showRegionPreview"
            defaultValue: false
        }

        Separator {}

        SliderSettingPlus {
            id: triggerAdjustment
            label: I18n.tr("Trigger area adjustment")
            description: I18n.tr("Fine-tune the trigger zone size. Positive values expand it, negative values shrink it.")
            settingKey: "triggerAdjustment"
            defaultValue: 0
            minimum: -150
            maximum: 500
            unit: "px"
            leftLabel: "-150"
            rightLabel: "500"
        }
    }

    SettingsCard {
        id: exclusionsSection
        SectionTitle { 
            text: I18n.tr("Exclusions")
            icon: "block" 
            showReset: excludeTray.isDirty || excludeClock.isDirty || hideCount.isDirty
            onResetClicked: {
                excludeTray.resetToDefault();
                excludeClock.resetToDefault();
                hideCount.resetToDefault();
            }
        }

        ToggleSettingPlus {
            id: excludeTray
            label: I18n.tr("Keep System Tray")
            description: I18n.tr("Never hide the system tray widgets.")
            settingKey: "excludeTray"
            defaultValue: true
        }

        Separator {}

        ToggleSettingPlus {
            id: excludeClock
            label: I18n.tr("Keep Clock")
            description: I18n.tr("Never hide the clock widget.")
            settingKey: "excludeClock"
            defaultValue: true
        }

        Separator {}

        SliderSettingPlus {
            id: hideCount
            label: I18n.tr("Max hidden widgets")
            description: I18n.tr("Limit the number of widgets to hide. Set to 0 to hide all.")
            settingKey: "hideCount"
            defaultValue: 0
            minimum: 0
            maximum: 20
            leftLabel: "0"
            rightLabel: "20"
        }
    }

    SettingsCard {
        SectionTitle { 
            id: ipcTitle
            text: I18n.tr("IPC Commands")
            icon: "terminal" 
            collapsible: true
            isExpanded: false
            settingKey: "ipcCommandsExpanded"
        }

        Column {
            width: parent.width
            spacing: Theme.spacingM
            visible: ipcTitle.isExpanded

            CopyBox {
                label: I18n.tr("Toggle Expansion")
                text: "dms ipc call hiddenBar toggle"
            }

            CopyBox {
                label: I18n.tr("Expand Area")
                text: "dms ipc call hiddenBar expand"
            }

            CopyBox {
                label: I18n.tr("Collapse Area")
                text: "dms ipc call hiddenBar collapse"
            }

            CopyBox {
                label: I18n.tr("Pin Expansion")
                text: "dms ipc call hiddenBar pin"
            }

            CopyBox {
                label: I18n.tr("Unpin Expansion")
                text: "dms ipc call hiddenBar unpin"
            }
        }
    }

    SettingsCard {
        SectionTitle { 
            id: usageTitle
            text: I18n.tr("Usage Guide")
            icon: "menu_book" 
            collapsible: true
            settingKey: "usageGuideExpanded"
        }

        UsageGuide {
            expanded: usageTitle.isExpanded
            items: [
                I18n.tr("<b>Hover</b> the icon (or trigger zone) to temporarily expand the hidden area."),
                I18n.tr("<b>Left-click</b> the icon to manually toggle the expanded state."),
                I18n.tr("<b>Right-click</b> the icon while expanded to <b>PIN</b> (prevent auto-collapse).")
            ]
        }
    }

    PluginAbout {
        repoUrl: "https://github.com/hthienloc/dms-hidden-bar"
    }
}
