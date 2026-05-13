import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool isExpanded: true
    
    // List of widget IDs that we are currently managing/hiding
    property var managedWidgets: []

    readonly property bool autoExpand: pluginData.autoExpand ?? true
    readonly property int hoverDelay: pluginData.hoverDelay ?? 0
    readonly property bool excludeTray: pluginData.excludeTray ?? true
    readonly property bool excludeClock: pluginData.excludeClock ?? true
    readonly property bool autoCollapse: pluginData.autoCollapse ?? false
    readonly property int collapseDelay: pluginData.collapseDelay ?? 5000

    function updateWidgets() {
        if (!root.parentScreen) return;
        
        let myScreen = root.parentScreen.name;
        let mySection = root.section;
        
        if (!root.parent || !root.parent.parent) return;
        
        let myPos = root.isVertical ? root.parent.parent.y : root.parent.parent.x;
        
        let allIds = BarWidgetService.getRegisteredWidgetIds();
        let foundWidgets = [];
        
        for (let i = 0; i < allIds.length; i++) {
            let id = allIds[i];
            if (id === root.pluginId) continue;
            
            // Exclusion logic
            if (root.excludeTray && (id === "systray" || id.includes("tray"))) continue;
            if (root.excludeClock && (id === "clock" || id === "time")) continue;
            
            let widget = BarWidgetService.getWidget(id, myScreen);
            if (widget && widget.section === mySection && widget.parent && widget.parent.parent) {
                let widgetPos = root.isVertical ? widget.parent.parent.y : widget.parent.parent.x;
                let shouldManage = false;
                
                // FLIPPED LOGIC: Hide widgets towards the center
                if (mySection === "right") {
                    // On the right section, smaller X is closer to the center
                    shouldManage = (widgetPos < myPos);
                } else if (mySection === "left") {
                    // On the left section, larger X is closer to the center
                    shouldManage = (widgetPos > myPos);
                } else if (mySection === "center") {
                    shouldManage = true;
                }
                
                if (shouldManage) {
                    widget.parent.visible = root.isExpanded;
                    foundWidgets.push(id);
                }
            }
        }
        root.managedWidgets = foundWidgets;
    }

    pillClickAction: function() {
        root.isExpanded = !root.isExpanded;
        updateWidgets();
        if (root.isExpanded && root.autoCollapse) {
            collapseTimer.restart();
        } else {
            collapseTimer.stop();
        }
    }

    // Hover expand logic using HoverHandler for better reliability
    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                if (root.autoExpand && !root.isExpanded) {
                    hoverTimer.interval = root.hoverDelay;
                    hoverTimer.start();
                }
                // Keep expanded if already expanded and auto-collapse is on
                if (root.isExpanded && root.autoCollapse) {
                    collapseTimer.stop();
                }
            } else {
                hoverTimer.stop();
                if (root.isExpanded && root.autoCollapse) {
                    collapseTimer.restart();
                }
            }
        }
    }

    Timer {
        id: hoverTimer
        repeat: false
        onTriggered: {
            if (!root.isExpanded) {
                root.isExpanded = true;
                updateWidgets();
                if (root.autoCollapse) {
                    collapseTimer.restart();
                }
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: root.collapseDelay
        repeat: false
        onTriggered: {
            if (root.isExpanded) {
                root.isExpanded = false;
                updateWidgets();
            }
        }
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: pillIcon.implicitWidth
            implicitHeight: 24
            
            DankIcon {
                id: pillIcon
                anchors.centerIn: parent
                name: {
                    if (root.section === "right") {
                        return root.isExpanded ? "chevron_left" : "chevron_right"
                    } else if (root.section === "left") {
                        return root.isExpanded ? "chevron_right" : "chevron_left"
                    }
                    return root.isExpanded ? "view-conceal-symbolic" : "view-visible-symbolic"
                }
                size: Theme.iconSizeSmall
                color: Theme.surfaceText
                opacity: root.isExpanded ? 1.0 : 0.6
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    verticalBarPill: horizontalBarPill
    
    Connections {
        target: BarWidgetService
        function onWidgetRegistered(id, screen) {
            if (!root.isExpanded) {
                reEvalTimer.restart();
            }
        }
    }
    
    Timer {
        id: reEvalTimer
        interval: 100
        repeat: false
        onTriggered: updateWidgets()
    }
}
