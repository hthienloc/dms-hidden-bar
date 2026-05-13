import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
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
    property var _sizeCache: ({}) // Cache for widget sizes
    property bool anyHovered: false
    property bool isMouseInGlobalZone: false

    onIsMouseInGlobalZoneChanged: updateAnyHovered()

    function updateAnyHovered() {
        if (isMouseInGlobalZone) {
            hoverGraceTimer.stop();
            anyHovered = true;
        } else {
            // Use grace period when expanded to prevent flicker during layout shifts
            if (root.isExpanded) {
                if (!hoverGraceTimer.running) hoverGraceTimer.restart();
            } else {
                anyHovered = false;
            }
        }
    }

    function checkGlobalMouse() {
        if (!Quickshell.cursor || !Quickshell.cursor.pos) {
            isMouseInGlobalZone = false;
            return;
        }

        // Get pill global position
        let globalPos = root.mapToItem(null, 0, 0);
        let x = globalPos.x;
        let y = globalPos.y;
        let w = root.width;
        let h = root.height;
        
        // expansion needs to be at least some value to allow triggering from empty space
        let expansion = Math.max(root.hiddenAreaSize, 200);
        
        // Expand detection area based on section and orientation
        if (root.isVertical) {
            // In vertical bars, "right" section is actually the bottom, "left" is top
            if (root.section === "right") { // Bottom-to-top
                y -= expansion;
                h += expansion;
            } else if (root.section === "left") { // Top-to-bottom
                h += expansion;
            } else { // Center - expand both ways
                y -= expansion / 2;
                h += expansion;
            }
        } else {
            if (root.section === "right") { // Right-to-left
                x -= expansion;
                w += expansion;
            } else if (root.section === "left") { // Left-to-right
                w += expansion;
            } else { // Center - expand both ways
                x -= expansion / 2;
                w += expansion;
            }
        }
        
        // Use a generous margin to ensure stability
        let margin = 40;
        let mx = Quickshell.cursor.pos.x;
        let my = Quickshell.cursor.pos.y;
        
        root.isMouseInGlobalZone = (mx >= x - margin && mx <= x + w + margin && 
                                    my >= y - margin && my <= y + h + margin);
    }

    Timer {
        id: globalMouseTimer
        interval: 33 // ~30fps for smooth detection
        repeat: true
        running: true
        onTriggered: checkGlobalMouse()
    }

    Timer {
        id: hoverGraceTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (!root.isMouseInGlobalZone) {
                root.anyHovered = false;
            }
        }
    }

    onAnyHoveredChanged: handleHover(anyHovered)

    function handleHover(hovered) {
        if (hovered) {
            if (root.autoExpand && !root.isExpanded) {
                hoverTimer.interval = root.hoverDelay;
                hoverTimer.restart();
            }
            collapseTimer.stop();
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
            
            if (root.excludeTray && (id === "systray" || id.includes("tray"))) continue;
            if (root.excludeClock && (id === "clock" || id === "time")) continue;
            
            let widget = BarWidgetService.getWidget(id, myScreen);
            if (widget && widget.section === mySection && widget.parent && widget.parent.parent) {
                let widgetPos = root.isVertical ? widget.parent.parent.y : widget.parent.parent.x;
                let shouldManage = false;
                
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
                
                // Get size, using cache if current size is 0 (hidden)
                let currentSize = root.isVertical ? (c.widget.implicitHeight || c.widget.parent.parent.height) 
                                               : (c.widget.implicitWidth || c.widget.parent.parent.width);
                
                if (currentSize > 0) {
                    root._sizeCache[c.id] = currentSize;
                }
                
                let size = currentSize > 0 ? currentSize : (root._sizeCache[c.id] || 0);
                if (size > 0) totalSize += size;
            } else {
                c.widget.parent.visible = true;
            }
        }
        
        if (totalSize > 0) {
            let newSize = totalSize + Theme.spacingM;
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
            reEvalTimer.restart();
        }
    }
    
    Timer {
        id: reEvalTimer
        interval: 100
        repeat: false
        onTriggered: updateWidgets()
    }
}
