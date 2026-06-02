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
            showReset: startExpanded.isDirty || autoExpand.isDirty || hoverDelay.isDirty || autoCollapse.isDirty || collapseDelay.isDirty
            onResetClicked: {
                startExpanded.resetToDefault();
                autoExpand.resetToDefault();
                hoverDelay.resetToDefault();
                autoCollapse.resetToDefault();
                collapseDelay.resetToDefault();
            }
        }

        ToggleSettingPlus {
            id: startExpanded
            label: I18n.tr("Start expanded")
            settingKey: "startExpanded"
            defaultValue: false
        }

        Separator {}

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

        Separator {
            visible: autoCollapse.value
            height: visible ? 1 : 0
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
