import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool isExpanded: pluginData.startExpanded ?? false
    
    Component.onCompleted: reEvalTimer.restart()

    // List of widget IDs that we are currently managing/hiding
    property var managedWidgets: []

    readonly property bool autoExpand: pluginData.autoExpand ?? true
    readonly property int hoverDelay: pluginData.hoverDelay ?? 0
    readonly property bool excludeTray: pluginData.excludeTray ?? true
    readonly property bool excludeClock: pluginData.excludeClock ?? true
    readonly property bool autoCollapse: pluginData.autoCollapse ?? true
    readonly property int collapseDelay: pluginData.collapseDelay ?? 1000
    readonly property bool extendedTrigger: pluginData.extendedTrigger ?? true
    readonly property int hideCount: pluginData.hideCount ?? 0

    property real hiddenAreaSize: 0
    property bool isPillHovered: false
    property bool isExtendedHovered: false
    readonly property bool anyHovered: isPillHovered || isExtendedHovered

    onAnyHoveredChanged: handleHover(anyHovered)

    function handleHover(hovered) {
        if (hovered) {
            if (root.autoExpand && !root.isExpanded) {
                hoverTimer.interval = root.hoverDelay;
                hoverTimer.start();
            }
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

    function updateWidgets() {
        if (!root.parentScreen) return;
        
        let myScreen = root.parentScreen.name;
        let mySection = root.section;
        
        if (!root.parent || !root.parent.parent) return;
        
        let myPos = root.isVertical ? root.parent.parent.y : root.parent.parent.x;
        let allIds = BarWidgetService.getRegisteredWidgetIds();
        
        let candidates = [];
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
                    shouldManage = (widgetPos < myPos);
                } else if (mySection === "left") {
                    shouldManage = (widgetPos > myPos);
                } else if (mySection === "center") {
                    shouldManage = true;
                }
                
                if (shouldManage) {
                    candidates.push({
                        id: id,
                        widget: widget,
                        pos: widgetPos,
                        dist: Math.abs(widgetPos - myPos)
                    });
                }
            }
        }
        
        // Sort by distance to pill (closest first)
        candidates.sort((a, b) => a.dist - b.dist);
        
        let limit = (root.hideCount > 0) ? root.hideCount : candidates.length;
        let foundIds = [];
        let totalSize = 0;
        
        for (let j = 0; j < candidates.length; j++) {
            let c = candidates[j];
            let shouldBeHidden = (j < limit);
            
            if (shouldBeHidden) {
                c.widget.parent.visible = root.isExpanded;
                foundIds.push(c.id);
                
                // Try to get the size. We use implicitSize because it might be available even when hidden.
                let w = root.isVertical ? (c.widget.implicitHeight || c.widget.parent.parent.height) 
                                        : (c.widget.implicitWidth || c.widget.parent.parent.width);
                if (w > 0) {
                    totalSize += w;
                }
            } else {
                c.widget.parent.visible = true;
            }
        }
        
        // Update hiddenAreaSize if we found a valid size. 
        // We only update if totalSize > 0 to avoid resetting to 0 when widgets are hidden.
        if (totalSize > 0) {
            let newSize = totalSize + Theme.spacingM;
            // Use a small threshold to avoid constant updates if implicitWidth fluctuates slightly
            if (Math.abs(root.hiddenAreaSize - newSize) > 1) {
                root.hiddenAreaSize = newSize;
            }
        }
        root.managedWidgets = foundIds;
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

    // Hover expand logic using HoverHandler
    HoverHandler {
        id: hoverHandler
        onHoveredChanged: root.isPillHovered = hovered
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
            
            // Extended trigger area that covers where hidden icons were
            Item {
                id: extendedTriggerArea
                // Keep visible even when expanded to prevent hover-loss loops
                visible: root.extendedTrigger && root.hiddenAreaSize > 0
                
                width: root.isVertical ? parent.width : root.hiddenAreaSize
                height: root.isVertical ? root.hiddenAreaSize : parent.height
                
                // Position based on section and orientation
                anchors.right: !root.isVertical && root.section === "right" ? parent.left : undefined
                anchors.left: !root.isVertical && root.section === "left" ? parent.right : undefined
                anchors.bottom: root.isVertical && root.section === "right" ? parent.top : undefined
                anchors.top: root.isVertical && root.section === "left" ? parent.bottom : undefined

                HoverHandler {
                    onHoveredChanged: root.isExtendedHovered = hovered
                }
                
                // Debug visual (commented out)
                /* Rectangle {
                    anchors.fill: parent
                    color: "red"
                    opacity: 0.2
                } */
            }

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
            reEvalTimer.restart();
        }
    }
    
    Timer {
        id: reEvalTimer
        interval: 10
        repeat: false
        onTriggered: updateWidgets()
    }
}
