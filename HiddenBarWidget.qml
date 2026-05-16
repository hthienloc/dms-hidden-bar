import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool isExpanded: pluginData.startExpanded ?? false
    
    Component.onCompleted: reEvalTimer.restart()


    readonly property bool autoExpand: pluginData.autoExpand ?? true
    readonly property int hoverDelay: pluginData.hoverDelay ?? 0
    readonly property bool excludeTray: pluginData.excludeTray ?? true
    readonly property bool excludeClock: pluginData.excludeClock ?? true
    readonly property bool autoCollapse: pluginData.autoCollapse ?? true
    readonly property int collapseDelay: pluginData.collapseDelay ?? 1000

    property bool isPinned: false
    readonly property int expandedHeight: Theme.iconSizeLarge + Theme.spacingM
    readonly property int collapsedHeight: 4
    readonly property int spacing: Theme.spacingS
    readonly property bool extendedTrigger: pluginData.extendedTrigger ?? true
    readonly property int hideCount: pluginData.hideCount ?? 0
    readonly property bool showRegionPreview: pluginData.showRegionPreview ?? false
    readonly property int triggerAdjustment: pluginData.triggerAdjustment ?? 0

    property real hiddenAreaSize: 0
    property var _sizeCache: ({}) // Cache for widget sizes
    property bool anyHovered: false
    property bool isMouseInGlobalZone: false
    

    onIsMouseInGlobalZoneChanged: {
        updateAnyHovered();
    }

    function updateAnyHovered() {
        if (isMouseInGlobalZone) {
            hoverGraceTimer.stop();
            anyHovered = true;
        } else {
            if (root.isExpanded) {
                if (!hoverGraceTimer.running) hoverGraceTimer.restart();
            } else {
                anyHovered = false;
            }
        }
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
            if (root.isExpanded && root.autoCollapse && !root.isPinned) {
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
                        dist: Math.abs(widgetPos - myPos)
                    });
                }
            }
        }
        
        candidates.sort((a, b) => a.dist - b.dist);
        
        let limit = (root.hideCount > 0) ? root.hideCount : candidates.length;
        let totalSize = 0;
        
        for (let j = 0; j < candidates.length; j++) {
            let c = candidates[j];
            let shouldBeHidden = (j < limit);
            
            if (shouldBeHidden) {
                if (c.widget.parent) {
                    c.widget.parent.visible = root.isExpanded;
                }
                
                // Get size, using cache if current size is 0 (hidden)
                let currentSize = root.isVertical ? (c.widget.implicitHeight || (c.widget.parent && c.widget.parent.parent ? c.widget.parent.parent.height : 0)) 
                                               : (c.widget.implicitWidth || (c.widget.parent && c.widget.parent.parent ? c.widget.parent.parent.width : 0));
                
                if (currentSize > 0) {
                    root._sizeCache[c.id] = currentSize;
                }
                
                let size = currentSize > 0 ? currentSize : (root._sizeCache[c.id] || 0);
                if (size > 0) totalSize += size;
            } else {
                if (c.widget.parent) {
                    c.widget.parent.visible = true;
                }
            }
        }
        
        // Cleanup cache for unregistered widgets
        let cacheKeys = Object.keys(root._sizeCache);
        for (let k = 0; k < cacheKeys.length; k++) {
            if (allIds.indexOf(cacheKeys[k]) === -1) {
                delete root._sizeCache[cacheKeys[k]];
            }
        }
        
        if (totalSize > 0) {
            let newSize = totalSize + Theme.spacingM;
            if (Math.abs(root.hiddenAreaSize - newSize) > 1) {
                root.hiddenAreaSize = newSize;
            }
        } else if (root.hiddenAreaSize !== 0) {
            root.hiddenAreaSize = 0;
        }
    }

    pillClickAction: function() {
        root.isExpanded = !root.isExpanded;
        root.isPinned = false;
        updateWidgets();
        
        // Only start collapse timer if expanded AND mouse is NOT in zone AND not pinned
        if (root.isExpanded && root.autoCollapse && !root.anyHovered && !root.isPinned) {
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
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: root.collapseDelay
        repeat: false
        onTriggered: {
            // Safety check: don't collapse if mouse returned to zone
            if (root.isExpanded && !root.anyHovered) {
                root.isExpanded = false;
                updateWidgets();
            }
        }
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: Theme.iconSizeSmall
            implicitHeight: Theme.iconSizeSmall
            
            DankIcon {
                id: pillIcon
                anchors.centerIn: parent
                size: Theme.iconSizeSmall
                name: {
                    if (root.isPinned) return "push_pin";
                    if (root.section === "right") {
                        return root.isExpanded ? "chevron_left" : "chevron_right"
                    } else if (root.section === "left") {
                        return root.isExpanded ? "chevron_right" : "chevron_left"
                    }
                    return root.isExpanded ? "view-conceal-symbolic" : "view-visible-symbolic"
                }
                color: Theme.surfaceText
                opacity: root.isExpanded ? 1.0 : 0.6
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
            
            Rectangle {
                id: pinIndicator
                width: Theme.spacingXS
                height: Theme.spacingXS
                radius: width / 2
                color: Theme.primary
                visible: root.isPinned
                anchors {
                    right: parent.right
                    rightMargin: -Theme.spacingXS / 2
                    top: parent.top
                    topMargin: Theme.spacingXS / 2
                }
            }
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        if (root.isExpanded) {
                            root.isPinned = !root.isPinned;
                        } else {
                            root.isPinned = false;
                        }
                    }
                }
            }
        }
    }

    verticalBarPill: horizontalBarPill
    
    Connections {
        target: BarWidgetService
        function onWidgetRegistered(id, screen) {
            if (root.parentScreen && screen === root.parentScreen.name) {
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

    MouseArea {
        id: triggerZone
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor
        
        readonly property real baseExpansion: (root.extendedTrigger || root.isExpanded) ? Math.max(root.hiddenAreaSize, 200) : 0
        readonly property real expansion: Math.max(0, baseExpansion + root.triggerAdjustment)
        
        width: {
            if (root.isVertical) return root.width;
            return root.width + expansion;
        }
        height: {
            if (!root.isVertical) return root.height;
            return root.height + expansion;
        }
        
        x: {
            if (root.isVertical) return 0;
            if (root.section === "right") return -expansion;
            if (root.section === "center") return -expansion / 2;
            return 0; // left section
        }
        y: {
            if (!root.isVertical) return 0;
            if (root.section === "right") return -expansion; // bottom-to-top
            if (root.section === "center") return -expansion / 2;
            return 0; // top-to-bottom
        }
        
        onContainsMouseChanged: {
            root.isMouseInGlobalZone = containsMouse;
        }
    }

    Rectangle {
        id: regionPreview
        visible: root.showRegionPreview
        x: triggerZone.x
        y: triggerZone.y
        width: triggerZone.width
        height: triggerZone.height
        color: Theme.primary
        opacity: 0.2
        border.color: Theme.primary
        border.width: 1
        z: 999 // Ensure it's visible over other widgets
    }
}
