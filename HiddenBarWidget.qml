import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginComponent {
    id: pluginRoot

    property bool isExpanded: pluginData.startExpanded ?? false
    readonly property bool autoExpand: pluginData.autoExpand ?? true
    readonly property int hoverDelay: pluginData.hoverDelay ?? 0
    readonly property bool excludeTray: pluginData.excludeTray ?? true
    readonly property bool excludeClock: pluginData.excludeClock ?? true
    readonly property bool autoCollapse: pluginData.autoCollapse ?? true
    readonly property int collapseDelay: {
        const val = pluginData.collapseDelay ?? 1;
        return val <= 100 ? val * 1000 : val;
    }
    property bool isPinned: false
    readonly property int expandedHeight: Theme.iconSizeLarge + Theme.spacingM
    readonly property int collapsedHeight: 4
    readonly property int spacing: Theme.spacingS
    readonly property bool extendedTrigger: pluginData.extendedTrigger ?? true
    readonly property int hideCount: pluginData.hideCount ?? 0
    readonly property bool showRegionPreview: pluginData.showRegionPreview ?? false
    readonly property int triggerAdjustment: pluginData.triggerAdjustment ?? 0
    readonly property bool usePopout: pluginData.usePopout ?? false
    readonly property string popoutLayout: pluginData.popoutLayout ?? "row"
    onUsePopoutChanged: updateWidgets()
    property var hiddenPluginIds: []
    property bool _popoutVisible: false
    property bool _popoutHovered: false
    property real hiddenAreaSize: 0

    readonly property int _popoutInternalMargin: Theme.spacingS // From PluginPopout.qml
    readonly property real _totalManagedWidth: {
        let w = 0;
        for (let i = 0; i < hiddenPluginIds.length; i++) {
            let id = hiddenPluginIds[i];
            w += (pluginRoot._sizeCache[id] || Theme.iconSizeSmall);
        }
        if (hiddenPluginIds.length > 1) {
            w += (hiddenPluginIds.length - 1) * Theme.spacingM;
        }
        return w;
    }
    property var _sizeCache: ({
    }) // Cache for widget sizes
    property bool anyHovered: false
    property bool isMouseInGlobalZone: false

    function updateAnyHovered() {
        if (isMouseInGlobalZone || _popoutHovered) {
            hoverGraceTimer.stop();
            anyHovered = true;
        } else {
            if (pluginRoot.isExpanded) {
                if (!hoverGraceTimer.running)
                    hoverGraceTimer.restart();

            } else {
                anyHovered = false;
            }
        }
    }

    // Helper to get screen coordinates of the main bar pill.
    // This MUST be called from the bar window context to get correct global coordinates.
    function getMainPillScreenPos() {
        const pill = isVertical ? verticalPill : horizontalPill;
        if (!pill || !pill.visualContent) return { x: 0, y: 0, width: 0 };
        
        const globalPos = pill.visualContent.mapToItem(null, 0, 0);
        const currentScreen = parentScreen || Screen;
        const barPosition = axis?.edge === "left" ? 2 : (axis?.edge === "right" ? 3 : (axis?.edge === "top" ? 0 : 1));
        return SettingsData.getPopupTriggerPosition(globalPos, currentScreen, barThickness, pill.visualWidth, barSpacing, barPosition, barConfig);
    }

    function handleHover(hovered) {
        if (hovered) {
            const isOpened = pluginRoot.usePopout ? pluginRoot._popoutVisible : pluginRoot.isExpanded;
            if (pluginRoot.autoExpand && !isOpened) {
                hoverTimer.interval = pluginRoot.hoverDelay;
                hoverTimer.restart();
            }
            collapseTimer.stop();
        } else {
            hoverTimer.stop();
            const isOpened = pluginRoot.usePopout ? pluginRoot._popoutVisible : pluginRoot.isExpanded;
            if (isOpened && pluginRoot.autoCollapse && !pluginRoot.isPinned)
                collapseTimer.restart();

        }
    }

    function updateWidgets() {
        if (!pluginRoot.parentScreen)
            return ;

        let myScreen = pluginRoot.parentScreen.name;
        let mySection = pluginRoot.section;
        if (!pluginRoot.parent || !pluginRoot.parent.parent)
            return ;

        let myPos = pluginRoot.isVertical ? pluginRoot.parent.parent.y : pluginRoot.parent.parent.x;
        let allIds = BarWidgetService.getRegisteredWidgetIds();
        let candidates = [];
        for (let i = 0; i < allIds.length; i++) {
            let id = allIds[i];
            if (id === pluginRoot.pluginId)
                continue;

            if (pluginRoot.excludeTray && (id === "systray" || id.includes("tray")))
                continue;

            if (pluginRoot.excludeClock && (id === "clock" || id === "time"))
                continue;

            let widget = BarWidgetService.getWidget(id, myScreen);
            if (widget && widget.section === mySection && widget.parent && widget.parent.parent) {
                let widgetPos = pluginRoot.isVertical ? widget.parent.parent.y : widget.parent.parent.x;
                let shouldManage = false;
                if (mySection === "right")
                    shouldManage = (widgetPos < myPos);
                else if (mySection === "left")
                    shouldManage = (widgetPos > myPos);
                else if (mySection === "center")
                    shouldManage = true;
                if (shouldManage)
                    candidates.push({
                    "id": id,
                    "widget": widget,
                    "dist": Math.abs(widgetPos - myPos)
                });

            }
        }
        candidates.sort((a, b) => {
            return a.dist - b.dist;
        });
        let limit = (pluginRoot.hideCount > 0) ? pluginRoot.hideCount : candidates.length;
        let totalSize = 0;
        let newHiddenIds = [];
        for (let j = 0; j < candidates.length; j++) {
            let c = candidates[j];
            let shouldBeHidden = (j < limit);
            if (shouldBeHidden) {
                if (pluginRoot.usePopout) {
                    newHiddenIds.push(c.id);
                    if (c.widget.parent)
                        c.widget.parent.visible = false;
                } else {
                    if (c.widget.parent)
                        c.widget.parent.visible = pluginRoot.isExpanded;
                }

                // Get size, using cache if current size is 0 (hidden)
                let currentSize = pluginRoot.isVertical ? (c.widget.implicitHeight || (c.widget.parent && c.widget.parent.parent ? c.widget.parent.parent.height : 0)) : (c.widget.implicitWidth || (c.widget.parent && c.widget.parent.parent ? c.widget.parent.parent.width : 0));
                if (currentSize > 0)
                    pluginRoot._sizeCache[c.id] = currentSize;

                let size = currentSize > 0 ? currentSize : (pluginRoot._sizeCache[c.id] || 0);
                if (size > 0)
                    totalSize += size;

            } else {
                if (c.widget.parent)
                    c.widget.parent.visible = true;

            }
        }
        pluginRoot.hiddenPluginIds = newHiddenIds;

        // Cleanup cache for unregistered widgets
        let cacheKeys = Object.keys(pluginRoot._sizeCache);
        for (let k = 0; k < cacheKeys.length; k++) {
            if (allIds.indexOf(cacheKeys[k]) === -1)
                delete pluginRoot._sizeCache[cacheKeys[k]];

        }
        if (totalSize > 0 && !pluginRoot.usePopout) {
            let newSize = totalSize + Theme.spacingM;
            if (Math.abs(pluginRoot.hiddenAreaSize - newSize) > 1)
                pluginRoot.hiddenAreaSize = newSize;

        } else if (pluginRoot.hiddenAreaSize !== 0) {
            pluginRoot.hiddenAreaSize = 0;
        }
    }

    Component.onCompleted: reEvalTimer.restart()
    onIsMouseInGlobalZoneChanged: {
        updateAnyHovered();
    }
    onAnyHoveredChanged: handleHover(anyHovered)
    pillClickAction: pluginRoot.usePopout ? null : function() {
        pluginRoot.isExpanded = !pluginRoot.isExpanded;
        pluginRoot.isPinned = false;
        updateWidgets();
        // Only start collapse timer if expanded AND mouse is NOT in zone AND not pinned
        if (pluginRoot.isExpanded && pluginRoot.autoCollapse && !pluginRoot.anyHovered && !pluginRoot.isPinned)
            collapseTimer.restart();
        else
            collapseTimer.stop();
    }
    verticalBarPill: horizontalBarPill

    popoutWidth: {
        if (pluginRoot.popoutLayout === "row") {
            if (hiddenPluginIds.length === 0) return 60;
            return _totalManagedWidth + Theme.spacingM * 2 + _popoutInternalMargin * 2;
        }
        return 240;
    }
    popoutHeight: pluginRoot.popoutLayout === "row" ? (pluginRoot.barThickness + Theme.spacingS * 2) : Math.ceil(hiddenPluginIds.length / 4) * (Theme.iconSizeSmall + Theme.spacingM) + Theme.spacingM * 2

    popoutContent: Component {
        PopoutComponent {
            headerText: ""
            showCloseButton: false
            
            Component.onCompleted: pluginRoot._popoutVisible = true
            Component.onDestruction: {
                pluginRoot._popoutVisible = false
                pluginRoot._popoutHovered = false
            }

            MouseArea {
                width: parent.width
                height: pluginRoot.popoutLayout === "row" ? pluginRoot.barThickness : undefined
                hoverEnabled: true
                onContainsMouseChanged: pluginRoot._popoutHovered = containsMouse
                propagateComposedEvents: true

                Loader {
                    anchors.fill: parent
                    sourceComponent: pluginRoot.popoutLayout === "grid" ? gridLayout : rowLayout
                }
            }

            Component {
                id: rowLayout
                Row {
                    width: parent.width
                    height: parent.height
                    spacing: Theme.spacingM
                    leftPadding: Theme.spacingM
                    rightPadding: Theme.spacingM
                    
                    Repeater {
                        model: pluginRoot.hiddenPluginIds
                        delegate: widgetDelegate
                    }
                }
            }

            Component {
                id: gridLayout
                Flow {
                    width: parent.width
                    spacing: Theme.spacingM
                    padding: Theme.spacingM
                    Repeater {
                        model: pluginRoot.hiddenPluginIds
                        delegate: widgetDelegate
                    }
                }
            }

            Component {
                id: widgetDelegate
                Item {
                    id: delegateRoot
                    implicitWidth: pluginRoot._sizeCache[modelData] || Theme.iconSizeSmall
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    
                    readonly property var originalWidget: {
                        if (!pluginRoot.parentScreen) return null;
                        return BarWidgetService.getWidget(modelData, pluginRoot.parentScreen.name);
                    }

                    Loader {
                        id: widgetLoader
                        readonly property string targetPluginId: modelData
                        anchors.fill: parent
                        
                        sourceComponent: PluginService.pluginWidgetComponents[targetPluginId] || null
                        
                        onLoaded: {
                            if (item) {
                                // 1. Standard init
                                if (item.pluginId !== undefined) item.pluginId = targetPluginId;
                                if (item.pluginService !== undefined) item.pluginService = PluginService;
                                if (item.popoutService !== undefined) item.popoutService = PopoutService;
                                if (item.isVertical !== undefined) item.isVertical = false;

                                // 2. Proxy Click Logic: Override click to trigger the REAL plugin
                                const original = delegateRoot.originalWidget;
                                if (original && item.hasOwnProperty("pillClickAction")) {
                                    item.pillClickAction = function() {
                                        // 1. Get position from Bar context
                                        const pos = pluginRoot.getMainPillScreenPos();
                                        const currentScreen = pluginRoot.parentScreen || Screen;
                                        const barPosition = pluginRoot.axis?.edge === "left" ? 2 : (pluginRoot.axis?.edge === "right" ? 3 : (pluginRoot.axis?.edge === "top" ? 0 : 1));
                                        
                                        // 2. Find original's popout object
                                        let targetPopout = null;
                                        for (let i = 0; i < original.children.length; i++) {
                                            const child = original.children[i];
                                            if (child.hasOwnProperty("shouldBeVisible") && child.hasOwnProperty("pluginContent")) {
                                                targetPopout = child;
                                                break;
                                            }
                                        }

                                        // 3. Close hidden bar popout
                                        pluginRoot.closePopout();

                                        // 4. Trigger real popout with "Ghost Mode"
                                        Qt.callLater(() => {
                                            if (targetPopout) {
                                                // Temporarily make original "visible" so popout isn't hidden by inheritance
                                                // but keep it transparent so it doesn't flicker on the bar
                                                if (original.parent) {
                                                    original.parent.visible = true;
                                                    original.parent.opacity = 0;
                                                }

                                                targetPopout.setTriggerPosition(
                                                    pos.x, pos.y, pos.width, 
                                                    pluginRoot.section, currentScreen,
                                                    barPosition, pluginRoot.barThickness, pluginRoot.barSpacing, pluginRoot.barConfig
                                                );
                                                
                                                // Listen for close to re-hide
                                                const cleanup = () => {
                                                    if (targetPopout.visible === false) {
                                                        if (original.parent) {
                                                            original.parent.visible = false;
                                                            original.parent.opacity = 1;
                                                        }
                                                        targetPopout.visibleChanged.disconnect(cleanup);
                                                    }
                                                };
                                                targetPopout.visibleChanged.connect(cleanup);
                                                
                                                targetPopout.open();
                                            } else {
                                                original.triggerPopout();
                                            }
                                        });
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: hoverGraceTimer

        interval: 500
        repeat: false
        onTriggered: {
            if (!pluginRoot.isMouseInGlobalZone)
                pluginRoot.anyHovered = false;

        }
    }

    Timer {
        id: hoverTimer

        repeat: false
        onTriggered: {
            if (pluginRoot.usePopout) {
                if (!pluginRoot._popoutVisible) {
                    pluginRoot.triggerPopout();
                }
            } else if (!pluginRoot.isExpanded) {
                pluginRoot.isExpanded = true;
                updateWidgets();
            }
        }
    }

    Timer {
        id: collapseTimer

        interval: pluginRoot.collapseDelay
        repeat: false
        onTriggered: {
            // Safety check: don't collapse if mouse returned to zone
            if (pluginRoot.anyHovered) return;

            if (pluginRoot.usePopout) {
                if (pluginRoot._popoutVisible) {
                    pluginRoot.closePopout();
                }
            } else if (pluginRoot.isExpanded) {
                pluginRoot.isExpanded = false;
                updateWidgets();
            }
        }
    }

    Connections {
        function onWidgetRegistered(id, screen) {
            if (pluginRoot.parentScreen && screen === pluginRoot.parentScreen.name)
                reEvalTimer.restart();

        }

        target: BarWidgetService
    }

    Timer {
        id: reEvalTimer

        interval: 100
        repeat: false
        onTriggered: updateWidgets()
    }

    IpcHandler {
        function toggle() : string {
            pluginRoot.isExpanded = !pluginRoot.isExpanded;
            pluginRoot.isPinned = false;
            updateWidgets();
            if (pluginRoot.isExpanded && pluginRoot.autoCollapse && !pluginRoot.anyHovered && !pluginRoot.isPinned)
                collapseTimer.restart();
            else
                collapseTimer.stop();
            return pluginRoot.isExpanded ? "EXPANDED" : "COLLAPSED";
        }

        function expand() : string {
            if (!pluginRoot.isExpanded) {
                pluginRoot.isExpanded = true;
                updateWidgets();
            }
            return "EXPANDED";
        }

        function collapse() : string {
            if (pluginRoot.isExpanded) {
                pluginRoot.isExpanded = false;
                pluginRoot.isPinned = false;
                updateWidgets();
            }
            return "COLLAPSED";
        }

        function pin() : string {
            if (!pluginRoot.isExpanded) {
                pluginRoot.isExpanded = true;
                updateWidgets();
            }
            pluginRoot.isPinned = true;
            collapseTimer.stop();
            return "PINNED";
        }

        function unpin() : string {
            pluginRoot.isPinned = false;
            if (pluginRoot.isExpanded && pluginRoot.autoCollapse && !pluginRoot.anyHovered)
                collapseTimer.restart();

            return "UNPINNED";
        }

        target: "hiddenBar"
    }

    MouseArea {
        id: triggerZone

        readonly property real baseExpansion: pluginRoot.extendedTrigger ? Math.max(pluginRoot.hiddenAreaSize, 200) : 0
        readonly property real expansion: Math.max(0, baseExpansion + pluginRoot.triggerAdjustment)

        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor
        width: {
            if (pluginRoot.isVertical)
                return pluginRoot.width;

            return pluginRoot.width + expansion;
        }
        height: {
            if (!pluginRoot.isVertical)
                return pluginRoot.height;

            return pluginRoot.height + expansion;
        }
        x: {
            if (pluginRoot.isVertical)
                return 0;

            if (pluginRoot.section === "right")
                return -expansion;

            if (pluginRoot.section === "center")
                return -expansion / 2;

            return 0; // left section
        }
        y: {
            if (!pluginRoot.isVertical)
                return 0;

            if (pluginRoot.section === "right")
                return -expansion;

            // bottom-to-top
            if (pluginRoot.section === "center")
                return -expansion / 2;

            return 0; // top-to-bottom
        }
        onContainsMouseChanged: {
            pluginRoot.isMouseInGlobalZone = containsMouse;
        }

        DropArea {
            anchors.fill: parent
            enabled: !pluginRoot.isExpanded
            onEntered: {
                pluginRoot.isMouseInGlobalZone = true;
            }
            onExited: {
                pluginRoot.isMouseInGlobalZone = false;
            }
        }
    }

    Rectangle {
        id: regionPreview

        visible: pluginRoot.showRegionPreview
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

    horizontalBarPill: Component {
        Item {
            implicitWidth: Theme.iconSizeSmall
            implicitHeight: Theme.iconSizeSmall

            DankIcon {
                id: pillIcon

                anchors.centerIn: parent
                size: Theme.iconSizeSmall
                name: {
                    if (pluginRoot.isPinned)
                        return "push_pin";

                    if (pluginRoot.usePopout)
                        return "expand_less";

                    if (pluginRoot.section === "right")
                        return pluginRoot.isExpanded ? "chevron_left" : "chevron_right";
                    else if (pluginRoot.section === "left")
                        return pluginRoot.isExpanded ? "chevron_right" : "chevron_left";
                    return pluginRoot.isExpanded ? "view-conceal-symbolic" : "view-visible-symbolic";
                }
                rotation: (pluginRoot.usePopout && pluginRoot._popoutVisible) ? 180 : 0
                color: Theme.surfaceText
                opacity: (pluginRoot.isExpanded || (pluginRoot.usePopout && pluginRoot._popoutVisible)) ? 1 : 0.6

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }

                }

            }

            Rectangle {
                id: pinIndicator

                width: Theme.spacingXS
                height: Theme.spacingXS
                radius: width / 2
                color: Theme.primary
                visible: pluginRoot.isPinned

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
                        if (pluginRoot.isExpanded)
                            pluginRoot.isPinned = !pluginRoot.isPinned;
                        else
                            pluginRoot.isPinned = false;
                    }
                }
            }

        }

    }

}
